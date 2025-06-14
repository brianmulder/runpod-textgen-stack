# Scripts

All scripts are located in `bin/` and expect environment variables defined in `.env`.

- **bootstrap.sh** – launches the RunPod pod, waits for it to be running, then starts `port-stick.sh` and installs certificates.
- **port-stick.sh** – maintains a `socat` tunnel from localhost to the pod.
- **fetch-cert.sh** – downloads the TLS certificate from the pod and trusts it on WSL and Windows.
- **nuke.sh** – stops the socat process and shuts down the pod.
