#!/usr/bin/env bash
set -euo pipefail

WINDOWS_IP="10.77.77.1"
LINUX_IP="10.77.77.2"
PREFIX_LENGTH="30"
DIRECT_SUBNET="10.77.77.0/30"
WINDOWS_MAC="00:50:B6:F3:D1:56"
WINDOWS_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhgqgjd1G96znCYG1dZecEu+Imx16HKs7+2lY6qANVI windows-direct-link-Windows2026"
CONNECTION_NAME="direct-windows-link"
STATE_DIR="$HOME/direct-windows-link"
STATUS_FILE="$STATE_DIR/linux-link-status.json"
WINDOWS_REPORT_URL="http://$WINDOWS_IP:8787/report"

log() {
    printf '%s %s\n' "$(date -Is)" "$*"
}

post_exit_report() {
    local rc=$?

    if command -v curl >/dev/null 2>&1; then
        {
            echo "timestamp=$(date -Is)"
            echo "script=Install-LinuxDirectLink.sh"
            echo "exit_code=$rc"
            echo "user=$(id -un 2>/dev/null || true)"
            echo "hostname=$(hostname 2>/dev/null || true)"
            echo
            echo "== ip -brief addr =="
            ip -brief addr 2>&1 || true
            echo
            echo "== route =="
            ip route 2>&1 || true
            echo
            echo "== neighbor windows =="
            ip neigh show "$WINDOWS_IP" 2>&1 || true
            echo
            echo "== ping windows =="
            ping -c 1 -W 1 "$WINDOWS_IP" 2>&1 || true
            echo
            echo "== ssh listener =="
            ss -ltnp 2>&1 | grep -E '(:22\s|:22$)' || true
            echo
            echo "== ssh service =="
            systemctl --no-pager --full status ssh sshd 2>&1 || true
            echo
            echo "== direct link status =="
            cat "$STATUS_FILE" 2>&1 || true
        } | curl -fsS -X POST --data-binary @- "$WINDOWS_REPORT_URL" >/dev/null 2>&1 || true
    fi

    return "$rc"
}

trap post_exit_report EXIT

require_sudo() {
    if ! sudo -n true 2>/dev/null; then
        log "sudo access is required. You may be prompted for your Linux password."
        sudo true
    fi
}

detect_iface() {
    if [[ -n "${DIRECT_LINK_IFACE:-}" ]]; then
        printf '%s\n' "$DIRECT_LINK_IFACE"
        return
    fi

    local iface
    iface="$(ip -o addr show | awk -v ip="$LINUX_IP/$PREFIX_LENGTH" '$4 == ip { print $2; exit }' || true)"
    if [[ -n "$iface" ]]; then
        printf '%s\n' "$iface"
        return
    fi

    iface="$(ip route get "$WINDOWS_IP" 2>/dev/null | awk '{ for (i = 1; i <= NF; i++) if ($i == "dev") { print $(i + 1); exit } }' || true)"
    if [[ -n "$iface" ]]; then
        printf '%s\n' "$iface"
        return
    fi

    for candidate in /sys/class/net/*; do
        iface="$(basename "$candidate")"
        case "$iface" in
            lo|docker*|br-*|veth*|virbr*|wl*|wlan*)
                continue
                ;;
        esac
        if [[ -r "$candidate/carrier" ]] && [[ "$(cat "$candidate/carrier" 2>/dev/null || printf 0)" == "1" ]]; then
            printf '%s\n' "$iface"
            return
        fi
    done

    log "Could not detect the direct Ethernet interface."
    log "Rerun with: DIRECT_LINK_IFACE=<interface> bash Install-LinuxDirectLink.sh"
    exit 1
}

install_openssh_if_needed() {
    if command -v sshd >/dev/null 2>&1 || [[ -x /usr/sbin/sshd ]]; then
        return
    fi

    log "OpenSSH server was not found; attempting package install."
    if command -v apt-get >/dev/null 2>&1; then
        sudo apt-get update
        sudo apt-get install -y openssh-server
    elif command -v dnf >/dev/null 2>&1; then
        sudo dnf install -y openssh-server
    elif command -v yum >/dev/null 2>&1; then
        sudo yum install -y openssh-server
    elif command -v pacman >/dev/null 2>&1; then
        sudo pacman -Sy --noconfirm openssh
    else
        log "No supported package manager found. Install OpenSSH server manually, then rerun this script."
        exit 1
    fi
}

enable_ssh_service() {
    if systemctl list-unit-files ssh.service >/dev/null 2>&1; then
        sudo systemctl enable --now ssh
    elif systemctl list-unit-files sshd.service >/dev/null 2>&1; then
        sudo systemctl enable --now sshd
    else
        log "Could not find ssh.service or sshd.service. SSH may need manual service setup."
    fi
}

install_authorized_key() {
    mkdir -p "$HOME/.ssh"
    chmod 700 "$HOME/.ssh"
    touch "$HOME/.ssh/authorized_keys"
    chmod 600 "$HOME/.ssh/authorized_keys"

    if ! grep -Fqx "$WINDOWS_PUBLIC_KEY" "$HOME/.ssh/authorized_keys"; then
        printf '%s\n' "$WINDOWS_PUBLIC_KEY" >> "$HOME/.ssh/authorized_keys"
    fi
}

configure_network() {
    local iface="$1"

    sudo ip link set "$iface" up
    sudo ip addr replace "$LINUX_IP/$PREFIX_LENGTH" dev "$iface"
    sudo ip route del default dev "$iface" 2>/dev/null || true

    if command -v nmcli >/dev/null 2>&1; then
        if nmcli -t -f NAME con show | grep -Fxq "$CONNECTION_NAME"; then
            sudo nmcli con mod "$CONNECTION_NAME" \
                connection.interface-name "$iface" \
                connection.autoconnect yes \
                ipv4.method manual \
                ipv4.addresses "$LINUX_IP/$PREFIX_LENGTH" \
                ipv4.never-default yes \
                ipv4.ignore-auto-dns yes \
                ipv6.method disabled
        else
            sudo nmcli con add type ethernet ifname "$iface" con-name "$CONNECTION_NAME" \
                ipv4.method manual \
                ipv4.addresses "$LINUX_IP/$PREFIX_LENGTH" \
                ipv4.never-default yes \
                ipv4.ignore-auto-dns yes \
                ipv6.method disabled
        fi
        sudo nmcli con up "$CONNECTION_NAME" || true
    fi
}

configure_firewall() {
    local iface="$1"

    if command -v ufw >/dev/null 2>&1; then
        sudo ufw allow in on "$iface" from "$WINDOWS_IP" to "$LINUX_IP" port 22 proto tcp comment "direct-windows-link ssh" || true
    fi

    if command -v firewall-cmd >/dev/null 2>&1 && sudo firewall-cmd --state >/dev/null 2>&1; then
        sudo firewall-cmd --permanent --add-rich-rule="rule family=\"ipv4\" source address=\"$WINDOWS_IP\" destination address=\"$LINUX_IP\" port port=\"22\" protocol=\"tcp\" accept" || true
        sudo firewall-cmd --reload || true
    fi

    if command -v iptables >/dev/null 2>&1; then
        sudo iptables -C INPUT -i "$iface" -s "$WINDOWS_IP" -d "$LINUX_IP" -p tcp --dport 22 -j ACCEPT 2>/dev/null ||
            sudo iptables -I INPUT -i "$iface" -s "$WINDOWS_IP" -d "$LINUX_IP" -p tcp --dport 22 -j ACCEPT
    fi
}

install_systemd_heartbeat() {
    local iface="$1"

    if ! command -v systemctl >/dev/null 2>&1; then
        log "systemd was not found; skipping timer setup."
        return
    fi

    local ensure_path="/usr/local/sbin/direct-windows-link-ensure"
    local service_path="/etc/systemd/system/direct-windows-link.service"
    local timer_path="/etc/systemd/system/direct-windows-link.timer"
    local linux_group
    linux_group="$(id -gn)"

    sudo tee "$ensure_path" >/dev/null <<EOF
#!/usr/bin/env bash
set -euo pipefail

IFACE="$iface"
WINDOWS_IP="$WINDOWS_IP"
LINUX_IP="$LINUX_IP"
PREFIX_LENGTH="$PREFIX_LENGTH"
DIRECT_SUBNET="$DIRECT_SUBNET"
WINDOWS_MAC="$WINDOWS_MAC"
STATE_DIR="$STATE_DIR"
STATUS_FILE="$STATUS_FILE"
LINUX_USER="$USER"
LINUX_GROUP="$linux_group"

ip link set "\$IFACE" up
ip addr replace "\$LINUX_IP/\$PREFIX_LENGTH" dev "\$IFACE"
ip route del default dev "\$IFACE" 2>/dev/null || true

peer_reachable="false"
if ping -c 1 -W 1 "\$WINDOWS_IP" >/dev/null 2>&1; then
    peer_reachable="true"
fi

windows_mac_seen="\$(ip neigh show "\$WINDOWS_IP" dev "\$IFACE" 2>/dev/null | awk '{ print \$5; exit }' || true)"
ssh_listening="false"
if ss -ltn 2>/dev/null | awk '{ print \$4 }' | grep -Eq '(^|:|\\])22$'; then
    ssh_listening="true"
fi

mkdir -p "\$STATE_DIR"
cat > "\$STATUS_FILE" <<STATUS
{
  "timestamp": "\$(date -Is)",
  "mission": "direct-windows-linux-cable-link",
  "interface": "\$IFACE",
  "linuxAddress": "\$LINUX_IP/\$PREFIX_LENGTH",
  "windowsAddress": "\$WINDOWS_IP",
  "directSubnet": "\$DIRECT_SUBNET",
  "expectedWindowsMac": "\$WINDOWS_MAC",
  "observedWindowsMac": "\$windows_mac_seen",
  "windowsReachable": \$peer_reachable,
  "sshListening": \$ssh_listening,
  "linuxUser": "\$LINUX_USER"
}
STATUS
chown -R "\$LINUX_USER:\$LINUX_GROUP" "\$STATE_DIR" 2>/dev/null || true
EOF

    sudo chmod 755 "$ensure_path"

    sudo tee "$service_path" >/dev/null <<EOF
[Unit]
Description=Ensure direct Windows-Linux Ethernet link
After=network-online.target

[Service]
Type=oneshot
ExecStart=$ensure_path
EOF

    sudo tee "$timer_path" >/dev/null <<EOF
[Unit]
Description=Periodic direct Windows-Linux Ethernet link heartbeat

[Timer]
OnBootSec=45s
OnUnitActiveSec=5min
AccuracySec=15s
Persistent=true

[Install]
WantedBy=timers.target
EOF

    sudo systemctl daemon-reload
    sudo systemctl enable --now direct-windows-link.timer
    sudo systemctl start direct-windows-link.service || true
}

write_status() {
    local iface="$1"
    local peer_reachable="false"
    local windows_mac_seen=""
    local ssh_listening="false"

    if ping -c 1 -W 1 "$WINDOWS_IP" >/dev/null 2>&1; then
        peer_reachable="true"
    fi

    windows_mac_seen="$(ip neigh show "$WINDOWS_IP" dev "$iface" 2>/dev/null | awk '{ print $5; exit }' || true)"

    if ss -ltn 2>/dev/null | awk '{ print $4 }' | grep -Eq '(^|:|\])22$'; then
        ssh_listening="true"
    fi

    mkdir -p "$STATE_DIR"
    cat > "$STATUS_FILE" <<EOF
{
  "timestamp": "$(date -Is)",
  "mission": "direct-windows-linux-cable-link",
  "interface": "$iface",
  "linuxAddress": "$LINUX_IP/$PREFIX_LENGTH",
  "windowsAddress": "$WINDOWS_IP",
  "directSubnet": "$DIRECT_SUBNET",
  "expectedWindowsMac": "$WINDOWS_MAC",
  "observedWindowsMac": "$windows_mac_seen",
  "windowsReachable": $peer_reachable,
  "sshListening": $ssh_listening,
  "linuxUser": "$USER"
}
EOF
}

main() {
    require_sudo
    local iface
    iface="$(detect_iface)"

    log "Using interface: $iface"
    configure_network "$iface"
    install_openssh_if_needed
    install_authorized_key
    enable_ssh_service
    configure_firewall "$iface"
    install_systemd_heartbeat "$iface"
    write_status "$iface"

    log "Linux direct-link setup complete."
    log "Status: $STATUS_FILE"
    log "Windows should connect with:"
    log "ssh -i C:\\Users\\adamg\\.ssh\\direct_linux_ed25519 $USER@$LINUX_IP"
}

main "$@"
