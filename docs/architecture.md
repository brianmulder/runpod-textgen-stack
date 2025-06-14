# Architecture

```text
OpenAI client -> localhost:8443 --+--> socat --> POD_IP:8443 --> stunnel --> web-ui
```

1. **socat** keeps a local port bound to the pod.
2. **stunnel** inside the pod terminates TLS and forwards to the web UI.
3. Models and certificates live on a RunPod network volume.
