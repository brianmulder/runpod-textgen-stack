# RunPod Text Generation Stack

A one-shot launcher for [text-generation-webui](https://github.com/oobabooga/text-generation-webui) on RunPod. Models persist on a network volume, and the API is served locally over HTTPS.

## Quick Start

1. Copy `.env.example` to `.env` and fill in the variables.
2. Run `./bin/bootstrap.sh` to launch the pod.
3. Point your OpenAI-compatible client to `https://localhost:8443/v1`.
4. When finished, run `./bin/nuke.sh` to stop the pod.

All scripts require Bash on WSL and `runpodctl` installed.
