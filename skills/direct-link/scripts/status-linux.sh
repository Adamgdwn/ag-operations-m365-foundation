#!/usr/bin/env bash
set -euo pipefail

WINDOWS_IP="${DIRECT_WINDOWS_IP:-10.77.77.1}"
LINUX_IP="${DIRECT_LINUX_IP:-10.77.77.2}"
CODE_PATH="${DIRECT_LINUX_CODE_PATH:-/home/adamgoodwin/code}"
EXCHANGE_PATH="${DIRECT_LINUX_EXCHANGE_PATH:-/home/adamgoodwin/DirectLink/Exchange}"
STATUS_FILE="${DIRECT_LINK_STATUS_FILE:-/home/adamgoodwin/direct-windows-link/linux-link-status.json}"

ping_ok=false
if ping -c 1 -W 2 "$WINDOWS_IP" >/dev/null 2>&1; then
  ping_ok=true
fi

code_ok=false
if [[ -d "$CODE_PATH" ]]; then
  code_ok=true
fi

exchange_ok=false
if [[ -d "$EXCHANGE_PATH" ]]; then
  exchange_ok=true
fi

status_file_ok=false
if [[ -f "$STATUS_FILE" ]]; then
  status_file_ok=true
fi

healthy=false
if [[ "$ping_ok" == "true" && "$code_ok" == "true" && "$exchange_ok" == "true" ]]; then
  healthy=true
fi

cat <<JSON
{
  "timestamp": "$(date --iso-8601=seconds)",
  "windowsIp": "$WINDOWS_IP",
  "linuxIp": "$LINUX_IP",
  "windowsPing": $ping_ok,
  "codePath": "$CODE_PATH",
  "codePathPresent": $code_ok,
  "exchangePath": "$EXCHANGE_PATH",
  "exchangePathPresent": $exchange_ok,
  "statusFile": "$STATUS_FILE",
  "statusFilePresent": $status_file_ok,
  "healthy": $healthy
}
JSON

if [[ "$healthy" == "true" ]]; then
  exit 0
fi

exit 1
