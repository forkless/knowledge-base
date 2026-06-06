# forkless - knowledge base

Documentation site for the **Ai, ai, ai! Bootstrap v0.1.1** - four scripts that set up a full local AI stack on Windows (Ollama, ComfyUI, Open Web UI), with a daily driver control panel.

Published at [forkless.github.io/knowledge-base](https://forkless.github.io/knowledge-base/).

## Repo structure

```
docs/       ← Jekyll site (GitHub Pages)
```

## Scripts

The bootstrap scripts live in the **companion repository**: [github.com/forkless/ai-ai-ai](https://github.com/forkless/ai-ai-ai)

- `scripts/1-init.ps1` - folder structure, GPU detection, config files
- `scripts/2-deps.ps1` - install Git, Python 3.10/3.11/3.12, Ollama, FFmpeg
- `scripts/3-apps.ps1` - ComfyUI + Open Web UI install, venv, GPU backend (CUDA / DirectML / ROCm), model paths
- `scripts/ai.ps1` - daily control panel (start/stop/status/doctor/install)

The companion repo also ships with `CHANGELOG.md`, `KNOWN_ISSUES.md`, `SOURCES.md` (software inventory), `tests/`, and `docs/` for additional reference.

Grab the [latest release](https://github.com/forkless/ai-ai-ai/releases) or clone the repo directly.
