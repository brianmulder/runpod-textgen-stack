# Architecture

```text
OpenAI client -> localhost:8443 --+--> socat --> POD_IP:$PUBLIC_PORT --> stunnel (443) --> web-ui
```

1. **socat** keeps a local port bound to the pod.
2. **setup-stunnel.sh** is uploaded after boot to install `stunnel` inside the pod.
3. **stunnel** terminates TLS and forwards to the web UI.
4. Models and certificates live on a RunPod network volume.
