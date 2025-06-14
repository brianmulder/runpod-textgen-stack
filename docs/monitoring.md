# Monitoring

The optional `watchdog.sh` script can poll `https://localhost:8444/v1/models` every 15 seconds. If the request fails five times, it restarts `port-stick.sh` or launches `bootstrap.sh --reconnect`.

Use `runpodctl get pod \$POD_ID --allfields | jq .runtime.totalCost` to monitor spending.
Logs are stored in `logs/health.log`.
