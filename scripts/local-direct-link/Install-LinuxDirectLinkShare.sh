#!/usr/bin/env bash
set -euo pipefail

WINDOWS_IP="10.77.77.1"
LINUX_IP="10.77.77.2"
DIRECT_INTERFACE="${DIRECT_INTERFACE:-enp55s0}"
DIRECT_USER="${DIRECT_USER:-adamgoodwin}"
SHARE_NAME="${SHARE_NAME:-agent-link}"
SHARE_PATH="${SHARE_PATH:-/home/$DIRECT_USER/AgentLink}"
SMB_CONF="/etc/samba/smb.conf"
STATUS_PATH="/home/$DIRECT_USER/direct-windows-link/linux-share-status.json"

require_sudo() {
    if ! sudo -n true 2>/dev/null; then
        echo "sudo access is required. You may be prompted for the Linux password."
        sudo true
    fi
}

read_samba_password() {
    if [[ -n "${DIRECT_LINK_SAMBA_PASSWORD:-}" ]]; then
        printf '%s\n' "$DIRECT_LINK_SAMBA_PASSWORD"
        return
    fi

    local password1 password2
    read -rsp "Samba password for $DIRECT_USER: " password1
    echo
    read -rsp "Confirm Samba password: " password2
    echo

    if [[ "$password1" != "$password2" ]]; then
        echo "Passwords did not match." >&2
        exit 1
    fi

    printf '%s\n' "$password1"
}

install_samba() {
    if command -v smbd >/dev/null 2>&1; then
        return
    fi

    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y samba
    else
        echo "Install Samba manually, then rerun this script." >&2
        exit 1
    fi
}

configure_share() {
    local samba_password="$1"

    sudo install -d -o "$DIRECT_USER" -g "$DIRECT_USER" -m 0770 "$SHARE_PATH"
    sudo install -d -o "$DIRECT_USER" -g "$DIRECT_USER" -m 0770 "/home/$DIRECT_USER/direct-windows-link"

    if [[ -f "$SMB_CONF" ]] && ! sudo test -f "$SMB_CONF.direct-link-backup"; then
        sudo cp "$SMB_CONF" "$SMB_CONF.direct-link-backup"
    fi

    local temp_conf
    temp_conf="$(mktemp)"
    sudo awk '
        /^# direct-windows-link managed block start$/ { skip = 1; next }
        /^# direct-windows-link managed block end$/ { skip = 0; next }
        skip != 1 { print }
    ' "$SMB_CONF" > "$temp_conf"

    cat >> "$temp_conf" <<EOF

# direct-windows-link managed block start
[global]
   interfaces = lo $DIRECT_INTERFACE $LINUX_IP/30
   bind interfaces only = yes
   hosts allow = $WINDOWS_IP 127.
   hosts deny = 0.0.0.0/0
   server min protocol = SMB3_00
   smb encrypt = required
   map to guest = Never
   usershare allow guests = no
   disable netbios = yes
   smb ports = 445

[$SHARE_NAME]
   path = $SHARE_PATH
   browseable = yes
   read only = no
   guest ok = no
   valid users = $DIRECT_USER
   force user = $DIRECT_USER
   force group = $DIRECT_USER
   create mask = 0660
   directory mask = 0770
# direct-windows-link managed block end
EOF

    sudo install -m 0644 "$temp_conf" "$SMB_CONF"
    rm -f "$temp_conf"

    printf '%s\n%s\n' "$samba_password" "$samba_password" | sudo smbpasswd -s -a "$DIRECT_USER" >/dev/null
    sudo smbpasswd -e "$DIRECT_USER" >/dev/null

    sudo testparm -s >/dev/null

    if command -v ufw >/dev/null 2>&1; then
        sudo ufw allow in on "$DIRECT_INTERFACE" from "$WINDOWS_IP" to "$LINUX_IP" port 445 proto tcp comment "direct-windows-link smb" || true
    fi

    sudo systemctl enable --now smbd
    sudo systemctl restart smbd
}

write_status() {
    local smb_listening="false"
    if ss -ltn 2>/dev/null | awk '{ print $4 }' | grep -Eq "(^|:)$LINUX_IP:445$|$LINUX_IP:445$"; then
        smb_listening="true"
    fi

    cat > "$STATUS_PATH" <<EOF
{
  "timestamp": "$(date -Is)",
  "mission": "direct-windows-linux-shared-workspace",
  "shareName": "$SHARE_NAME",
  "sharePath": "$SHARE_PATH",
  "linuxAddress": "$LINUX_IP",
  "windowsAddress": "$WINDOWS_IP",
  "interface": "$DIRECT_INTERFACE",
  "smbListening": $smb_listening,
  "security": {
    "smbEncryptionRequired": true,
    "guestAccess": false,
    "validUser": "$DIRECT_USER",
    "boundToDirectInterface": true,
    "allowedWindowsAddress": "$WINDOWS_IP"
  }
}
EOF
    chown "$DIRECT_USER:$DIRECT_USER" "$STATUS_PATH" 2>/dev/null || true
}

main() {
    require_sudo
    local samba_password
    samba_password="$(read_samba_password)"
    install_samba
    configure_share "$samba_password"
    write_status
    echo "Linux direct-link Samba share is ready: //$LINUX_IP/$SHARE_NAME"
    echo "Share path: $SHARE_PATH"
}

main "$@"
