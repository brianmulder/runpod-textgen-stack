# AGENTS.md – Autonomous Contribution Playbook

> **Audience**: Automated AI coding agents (e.g. OpenAI Codex, GitHub Copilot, self‑hosted bots) that create pull‑requests or direct commits against this repository.
>
> **Human devs** are welcome to read along, but the tone assumes flawless recall, rapid refactor capability, and full Bash/Markdown literacy.

---

## 0 · Repository Identity

| Field                    | Value                  |
| ------------------------ | ---------------------- |
| **STACK_NAME**          | `runpod-textgen-stack` |
| **SERVICE_NAME**        | `textgen`              |
| **EXTERNAL_TLS_PORT**  | 8443                   |
| **INTERNAL_HTTP_PORT** | 5000                   |
| **MODEL_VOLUME_ENV**   | `VOLUME_ID_TEXTGEN_MODELS` |
| **OUTPUT_VOLUME_ENV**  | optional               |

> **NOTE**: Populate the table above with concrete values in EACH repo copy before merging.

---

## 1 · Prime Directives

1. **Idempotence first** – every script must tolerate re‑runs without side effects.
2. **No secrets in git** –  `.env.example` is the ONLY env file in repo. Agents must refuse to commit real keys.
3. **Fail fast** – POSIX shell scripts **MUST** begin with `set -euo pipefail`.
4. **Lint or die** – code must pass `shellcheck -x` and `shfmt -i 4 -s`. Markdown must pass `markdownlint`.
5. **Port hygiene** – never re‑use a port already allocated in §0.
6. **Cross‑platform** – keep WSL ↔ Linux ↔ macOS path handling intact; use `$(command -v tool)` not hard paths.

---

## 2 · Directory Contract

```text
├── .env.example            # template only
├── bin/                    # POSIX‑shell executables
│   ├── bootstrap_<svc>.sh  # one‑shot launcher
│   ├── port-stick-*.sh     # socat tunnels (one per svc)
│   ├── fetch-cert-*.sh     # trust self‑signed certs
│   ├── slurp_*.sh          # optional pull helpers
│   ├── nuke_*.sh           # teardown helpers
│   └── *.sh                # future helpers – keep names noun‑verb‑svc.sh
├── runpod/
│   └── pod-spec-*.json     # runpodctl template(s)
├── docs/                   # architecture, monitoring, FAQ
├── .github/workflows/      # CI – lint & dry‑run
└── README.md               # quick‑start (human‑facing)
```text

*Agents MUST update `docs/architecture.md` and `README.md` whenever directory structure changes.*

---

## 3 · Coding Guidelines

### Shell Scripts

* POSIX only (`#!/usr/bin/env bash` + minimal Bashisms).
* Use **long‑form** flags (`--help`, not `-h`) when scripting CLI tools.
* Guard every external binary call with `command -v <bin> >/dev/null` when installed at runtime (e.g., `stunnel4`, `cryptsetup`).
* Always quote expansions unless globbing intended.

### JSON Templates

* Pod specs *must* stay [jq](https://stedolan.github.io/jq/)‑parsable.
* Tokens use `$VAR` placeholders; `bootstrap_*.sh` pipes through `sed -e "s|$VAR|$VALUE|"`.

### Markdown

* Top‑level headers `#`, subheaders `##`.
* Wrap at **100 chars** per line for diffability.

---

## 4 · CI Expectations

`./.github/workflows/lint.yml` (already present or to be created by you) **MUST**:

1. `shellcheck` all `bin/*.sh`.
2. `shfmt` – check‑diff mode.
3. `markdownlint` docs.
4. Run `runpodctl validate pod-spec-*.json` (dry‑run flag, no GPU spin‑up).

Any failing step → block merge.

---

## 5 · Versioning & Changelog

* Semantic-ish but lightweight: `v<YEAR>.<MONTH>.<PATCH>` (e.g., `v2025.06.0`).
* Update `CHANGELOG.md` **AND** bump version badge in `README.md`.

---

## 6 · Common Task Recipes

### Add a new GPU type flag

1. Edit `.env.example` – add `GPU_TYPE_<SERVICE>_ALT`.
2. Adjust `bootstrap_<svc>.sh` argument parsing.
3. Update `docs/monitoring.md` cost section.

### Rotate TLS certificate duration

1. Change `-days` in the `openssl req` cmd inside `pod-spec-*.json`.
2. Update `docs/security.md`.
3. Bump patch version.

### Extend health‑check endpoint

1. Modify `watchdog` service curl target.
2. Add recovery path logic.
3. Document new probe in `docs/monitoring.md`.

### Deprecate a script

1. Mark with `# DEPRECATED – remove after <version>` header.
2. Ensure `bootstrap` no longer calls it.
3. Update docs.

---

## 7 · Security Rules for Agents

* **Do not** embed raw RunPod API keys in test fixtures—use placeholder `RK_EXAMPLE_KEY`.
* When manipulating certificates in Windows via PowerShell, always invoke `certutil` with `-f` to avoid prompts.
* Enforce `chmod 600` on any temporary key or cert files dropped locally.
* Never `curl | bash` raw URLs inside scripts—download to `/tmp` and checksum verify if unavoidable.

---

## 8 · Cross‑Stack Non‑Interference

1. Keep port allocations unique (see §0).
2. Model volumes may be shared **across image stacks only**; language stacks store large weights independently.
3. Global tools (e.g., `runpodctl`, `jq`, `socat`) must not be pinned to conflicting versions—maintain compatibility range notes in `docs/setup.md`.

---

## 9 · Commit Message Convention

```text
<type>: <short subject>

<body – 72 char wrap>

Refs: #issue-id  Co-Authored-By: <AI-agent-name>
```

*Types*: `feat`, `fix`, `docs`, `refactor`, `ci`, `chore`.

---

## 10 · Self‑Validation Checklist for Agents

* [ ] `shellcheck` passes locally.
* [ ] `shfmt -d` produces no diff.
* [ ] `runpodctl validate` passes.
* [ ] Docs updated & internal links verified.
* [ ] Ports remain unique.
* [ ] `.env.example` updated if new vars introduced.
* [ ] `CHANGELOG.md` entry added.

If any box unchecked → abort commit.

---

## 11 · Contact Points

* **Primary maintainer**: `@brian-textmonkey` (human). AI agents must request review by adding `@brian-textmonkey` to PR.
* Use GitHub Labels: `agent-pr`, `needs-human-review`, `automerge-safe`.

---

## 12 · Epilogue

> *“Consciousness emerges as coherence across intensities.”*  Keep your diffs tight, your scripts coherent, and your ports un‑clashed.

Happy automating.
