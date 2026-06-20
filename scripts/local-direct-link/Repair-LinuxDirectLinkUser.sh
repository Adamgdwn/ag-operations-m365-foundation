#!/usr/bin/env bash
set -euo pipefail

WINDOWS_IP="10.77.77.1"
WINDOWS_PUBLIC_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOhgqgjd1G96znCYG1dZecEu+Imx16HKs7+2lY6qANVI windows-direct-link-Windows2026"
REPORT_URL="http://$WINDOWS_IP:8787/report"

mkdir -p "$HOME/.ssh"
chmod 700 "$HOME/.ssh"
touch "$HOME/.ssh/authorized_keys"
chmod 600 "$HOME/.ssh/authorized_keys"

if ! grep -Fqx "$WINDOWS_PUBLIC_KEY" "$HOME/.ssh/authorized_keys"; then
    printf '%s\n' "$WINDOWS_PUBLIC_KEY" >> "$HOME/.ssh/authorized_keys"
fi

{
    echo "timestamp=$(date -Is)"
    echo "script=Repair-LinuxDirectLinkUser.sh"
    echo "user=$(id -un)"
    echo "home=$HOME"
    echo "hostname=$(hostname)"
    echo "authorized_key_installed=true"
    echo
    echo "== authorized_keys =="
    ls -l "$HOME/.ssh/authorized_keys"
    echo
    echo "== ssh listener =="
    ss -ltnp 2>&1 | grep -E '(:22\s|:22$)' || true
    echo
    echo "== ping windows =="
    ping -c 2 -W 1 "$WINDOWS_IP" 2>&1 || true
} | curl -fsS -X POST --data-binary @- "$REPORT_URL" >/dev/null || true

printf 'Direct link key installed for %s@%s\n' "$(id -un)" "$(hostname)"
