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
: "${VOLUME_ID_TEXTGEN_MODELS:?VOLUME_ID_TEXTGEN_MODELS not set}"
: "${MODEL_DIR:=/workspace/models}"
: "${HOME_IP:=}"
: "${TLS_PORT:=8443}"
: "${API_PORT:=8444}"

POD_ID=$(runpodctl create pod \
    --name tg-webui \
    --gpuType "$GPU_TYPE" \
    --gpuCount 1 \
    --imageName atinoda/text-generation-webui:default-nightly \
    --containerDiskSize 40 \
    --networkVolumeId "$VOLUME_ID_TEXTGEN_MODELS" \
    --volumePath /workspace \
    --ports 443/tcp \
    --ports 444/tcp \
    --args "--listen --api --extensions openai --model-dir $MODEL_DIR" \
    --communityCloud | awk '/ID/ {print $NF}')

# Wait for running
while true; do
    STATUS=$(runpodctl get pod "$POD_ID" --allfields | jq -r '.desiredStatus')
    [ "$STATUS" = "RUNNING" ] && break
    sleep 5
done

POD_INFO=$(runpodctl get pod "$POD_ID" --allfields)
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
