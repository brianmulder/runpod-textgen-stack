# Architecture

```text
client https -> localhost:8443 -> socat -> POD_IP:$PUBLIC_UI -> stunnel (443 -> 7860) -> web UI
client https -> localhost:8444 -> socat -> POD_IP:$PUBLIC_API -> stunnel (444 -> 5000) -> API
```

1. **socat** keeps local ports bound to the pod.
2. **setup-stunnel.sh** installs `stunnel` in the pod after launch.
3. **stunnel** terminates TLS and forwards to the appropriate service.
4. Models and certificates live on a RunPod network volume.
