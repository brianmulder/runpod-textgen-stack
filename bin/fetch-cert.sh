#!/usr/bin/env bash
set -euo pipefail

: "${1:?pod IP required}"
POD_IP=$1
: "${2:?pod port required}"
POD_PORT=$2
CERT_FILE="runpod-tg.crt"

openssl s_client -connect "$POD_IP:$POD_PORT" -showcerts </dev/null 2>/dev/null |
    awk '/BEGIN CERTIFICATE/,/END CERTIFICATE/' >"$CERT_FILE"

sudo cp "$CERT_FILE" /usr/local/share/ca-certificates/
sudo update-ca-certificates

echo "Certificate installed"
