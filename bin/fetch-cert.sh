#!/usr/bin/env bash
set -euo pipefail

: "${1:?pod IP required}"
POD_IP=$1
: "${TLS_PORT:=8443}"
CERT_FILE="runpod-tg.crt"

openssl s_client -connect "$POD_IP:$TLS_PORT" -showcerts </dev/null 2>/dev/null |
    awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' >"$CERT_FILE"

sudo cp "$CERT_FILE" /usr/local/share/ca-certificates/
sudo update-ca-certificates

powershell.exe -Command \
    "Start-Process powershell -Verb runAs -ArgumentList \"-NoProfile -Command \"certutil -addstore -f Root $(wslpath -w $CERT_FILE)\"\""

echo "Certificate installed"
