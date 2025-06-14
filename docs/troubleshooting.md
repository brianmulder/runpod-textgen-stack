# Troubleshooting

| Gotcha | Symptom | Fix |
|-------|---------|-----|
| WSL clock skew | TLS cert not yet valid | `sudo hwclock -s` |
| Port in use | socat fails | change `TLS_PORT` in `.env` |
| GPU unavailable | pod creation fails | `runpodctl get gputypes` |
| Cert trust lost | Browser warns | run `bin/fetch-cert.sh \$POD_IP` |
| IP restricted | 403 on connect | update `HOME_IP` and redeploy |
