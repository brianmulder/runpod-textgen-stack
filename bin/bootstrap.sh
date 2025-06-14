#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
ROOT_DIR=$(dirname "$SCRIPT_DIR")

# Load environment variables
if [ -f "$ROOT_DIR/.env" ]; then
    # shellcheck disable=SC1090
    # shellcheck disable=SC1091
    source "$ROOT_DIR/.env"
else
    echo "Missing .env file" >&2
    exit 1
fi

: "${RUNPOD_API_KEY:?RUNPOD_API_KEY not set}"
: "${GPU_TYPE:?GPU_TYPE not set}"
: "${VOLUME_NAME:?VOLUME_NAME not set}"
: "${MODEL_DIR:=/workspace/models}"
: "${HOME_IP:=}"
: "${TLS_PORT:=8443}"
: "${API_PORT:=8444}"

POD_SPEC_TEMPLATE="$ROOT_DIR/runpod/pod-spec.json"
POD_SPEC="$ROOT_DIR/runpod/pod-spec-rendered.json"

# Ensure volume exists
VOLUME_ID=$(runpodctl get volume "$VOLUME_NAME" -o json | jq -r '.id' 2>/dev/null || true)
if [ -z "$VOLUME_ID" ]; then
    VOLUME_ID=$(runpodctl create volume --name "$VOLUME_NAME" --size 200 -o json | jq -r '.id')
fi

# Render pod spec
sed -e "s|\$GPU_TYPE|$GPU_TYPE|" \
    -e "s|\$VOLUME_ID|$VOLUME_ID|" \
    -e "s|\$MODEL_DIR|$MODEL_DIR|" \
    "$POD_SPEC_TEMPLATE" >"$POD_SPEC"

# Create pod
POD_ID=$(runpodctl create pod --spec "$POD_SPEC" -o json | jq -r '.id')

# Wait for running
while true; do
    STATUS=$(runpodctl get pod "$POD_ID" -o json | jq -r '.desiredStatus')
    [ "$STATUS" = "RUNNING" ] && break
    sleep 5
done

POD_INFO=$(runpodctl get pod "$POD_ID" -o json)
POD_IP=$(echo "$POD_INFO" | jq -r '.publicIp')
UI_PORT_REMOTE=$(echo "$POD_INFO" | jq -r '.ports[] | select(.containerPort==443) | .publicPort')
API_PORT_REMOTE=$(echo "$POD_INFO" | jq -r '.ports[] | select(.containerPort==444) | .publicPort')
cat >"$ROOT_DIR/.pod_env" <<EOF_POD
POD_ID=$POD_ID
POD_IP=$POD_IP
TLS_PORT=$TLS_PORT
API_PORT=$API_PORT
UI_PORT_REMOTE=$UI_PORT_REMOTE
API_PORT_REMOTE=$API_PORT_REMOTE
EOF_POD

# Send stunnel setup script and execute inside the pod
SETUP_SCRIPT="$ROOT_DIR/bin/setup-stunnel.sh"
SEND_OUTPUT=$(runpodctl send "$SETUP_SCRIPT")
CODE=$(echo "$SEND_OUTPUT" | awk '/runpodctl receive/ {print $2}')
runpodctl ssh "$POD_ID" -- "runpodctl receive $CODE && bash $(basename "$SETUP_SCRIPT")"

# Start port forwarder
"$SCRIPT_DIR/port-stick.sh" "$POD_IP" "$UI_PORT_REMOTE" "$TLS_PORT" &
PID_UI=$!
"$SCRIPT_DIR/port-stick.sh" "$POD_IP" "$API_PORT_REMOTE" "$API_PORT" &
PID_API=$!
echo "$PID_UI $PID_API" >"$ROOT_DIR/.port_stick.pid"

# Fetch certificate
"$SCRIPT_DIR/fetch-cert.sh" "$POD_IP" "$UI_PORT_REMOTE"

echo "UI available at https://localhost:$TLS_PORT"
echo "API available at https://localhost:$API_PORT"
