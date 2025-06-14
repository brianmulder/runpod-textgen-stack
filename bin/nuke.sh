#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

if [ -f "$ROOT_DIR/.port_stick.pid" ]; then
    while read -r pid; do
        kill "$pid" 2>/dev/null || true
    done <"$ROOT_DIR/.port_stick.pid"
    rm "$ROOT_DIR/.port_stick.pid"
fi

if [ -f "$ROOT_DIR/.pod_env" ]; then
    # shellcheck disable=SC1090
    # shellcheck disable=SC1091
    source "$ROOT_DIR/.pod_env"
    runpodctl stop pod "$POD_ID" || true
    # Uncomment to delete
    # runpodctl delete pod "$POD_ID" || true
    rm "$ROOT_DIR/.pod_env"
fi

rm -f "$ROOT_DIR/runpod/pod-spec-rendered.json"

echo "Pod stopped"
