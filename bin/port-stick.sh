#!/usr/bin/env bash
set -euo pipefail

: "${1:?pod IP required}"
POD_IP=$1
: "${TLS_PORT:=8443}"

while true; do
    socat TCP-LISTEN:"$TLS_PORT",reuseaddr,fork TCP:"$POD_IP":"$TLS_PORT" || true
    sleep 2
done
