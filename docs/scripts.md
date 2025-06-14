# Scripts

All scripts are located in `bin/` and expect environment variables defined in `.env`.

- **bootstrap.sh** – launches the RunPod pod, uploads `setup-stunnel.sh`, then starts
  two `port-stick.sh` tunnels and installs certificates. It sets `EXTRA_LAUNCH_ARGS`
  so the web UI starts with API support and the chosen `MODEL_DIR`.
- **setup-stunnel.sh** – runs inside the pod to install `stunnel` and generate certificates.
- **port-stick.sh** – maintains a `socat` tunnel from localhost to the pod's public port.
- **fetch-cert.sh** – downloads the TLS certificate from the pod and trusts it locally.
- **nuke.sh** – stops the socat process and shuts down the pod.
