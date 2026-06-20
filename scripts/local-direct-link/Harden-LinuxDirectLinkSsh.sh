#!/usr/bin/env bash
set -euo pipefail

DIRECT_USER="${1:-adamgoodwin}"
DIRECT_LISTEN_ADDRESS="10.77.77.2"
DIRECT_WINDOWS_ADDRESS="10.77.77.1"
CONF="/etc/ssh/sshd_config.d/90-direct-windows-link.conf"

if ! command -v sudo >/dev/null 2>&1; then
    echo "sudo is required to harden sshd config" >&2
    exit 1
fi

sudo tee "$CONF" >/dev/null <<EOF
# Managed direct Windows-Linux cable link.
# Mission: expose SSH only on the direct Ethernet address and require the dedicated key.
ListenAddress $DIRECT_LISTEN_ADDRESS
PubkeyAuthentication yes
PasswordAuthentication no
KbdInteractiveAuthentication no
PermitRootLogin no
AllowUsers $DIRECT_USER
MaxAuthTries 3
X11Forwarding no
AllowAgentForwarding no
EOF

if sudo sshd -t; then
    if systemctl list-unit-files ssh.service >/dev/null 2>&1; then
        sudo systemctl reload ssh
    elif systemctl list-unit-files sshd.service >/dev/null 2>&1; then
        sudo systemctl reload sshd
    else
        echo "Could not find ssh or sshd service to reload" >&2
        exit 1
    fi
else
    echo "sshd config test failed; not reloading" >&2
    exit 1
fi

echo "Hardened direct-link SSH for $DIRECT_USER from $DIRECT_WINDOWS_ADDRESS to $DIRECT_LISTEN_ADDRESS"
