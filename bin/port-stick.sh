#!/usr/bin/env bash
set -euo pipefail

: "${1:?pod IP required}"
POD_IP=$1
: "${2:?public port required}"
POD_PORT=$2
: "${3:?local port required}"
LOCAL_PORT=$3

while true; do
    socat TCP-LISTEN:"$LOCAL_PORT",reuseaddr,fork TCP:"$POD_IP":"$POD_PORT" || true
    sleep 2
done
