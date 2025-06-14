# RunPod Text Generation Stack

A one-shot launcher for
[text-generation-webui](https://github.com/oobabooga/text-generation-webui) on RunPod.
Models persist on a network volume, and the API is served locally over HTTPS.

## Quick Start

1. Copy `.env.example` to `.env` and fill in the variables.
2. Run `./bin/bootstrap.sh` to launch the pod. The script uploads `setup-stunnel.sh` and configures TLS.
   It maps the public port assigned by RunPod back to `https://localhost:8443`.
3. Point your OpenAI-compatible client to `https://localhost:8443/v1`.
4. When finished, run `./bin/nuke.sh` to stop the pod.

All scripts require Bash on WSL and `runpodctl` installed.

Run `make lint` to verify shell scripts, Markdown files, and the pod spec.
The command installs `shellcheck`, `shfmt`, `jq`, `markdownlint`, and
`python3-jsonschema` automatically if missing.
