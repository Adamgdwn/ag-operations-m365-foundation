#!/usr/bin/env bash
set -u

WINDOWS_HUB="http://10.77.77.1:8787/report"

{
    echo "timestamp=$(date -Is)"
    echo "user=$(id -un 2>/dev/null || true)"
    echo "hostname=$(hostname 2>/dev/null || true)"
    echo
    echo "== ip -brief addr =="
    ip -brief addr 2>&1 || true
    echo
    echo "== route =="
    ip route 2>&1 || true
    echo
    echo "== neighbor 10.77.77.1 =="
    ip neigh show 10.77.77.1 2>&1 || true
    echo
    echo "== ping windows =="
    ping -c 3 -W 1 10.77.77.1 2>&1 || true
    echo
    echo "== ssh listener =="
    ss -ltnp 2>&1 | grep -E '(:22\s|:22$)' || true
    echo
    echo "== ssh service =="
    systemctl --no-pager --full status ssh sshd 2>&1 || true
    echo
    echo "== sudo noninteractive =="
    sudo -n true 2>&1 && echo "sudo_noprompt=true" || echo "sudo_noprompt=false"
    echo
    echo "== openssh server files =="
    command -v sshd 2>&1 || true
    ls -l /usr/sbin/sshd /etc/ssh/sshd_config 2>&1 || true
    echo
    echo "== direct link status =="
    cat "$HOME/direct-windows-link/linux-link-status.json" 2>&1 || true
} | curl -fsS -X POST --data-binary @- "$WINDOWS_HUB"
