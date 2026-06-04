# forkless — knowledge base

Documentation site for the **Ai, ai, ai! Bootstrap** system — three scripts that set up a full local AI stack on Windows (Ollama, ComfyUI, Open Web UI), with a daily driver control panel.

Published at [forkless.github.io/knowledge-base](https://forkless.github.io/knowledge-base/).

## Repo structure

```
docs/       ← Jekyll site (GitHub Pages)
scripts/    ← stale local copy — see companion repo instead
```

## Scripts

The bootstrap scripts live in the **companion repository**: [github.com/forkless/ai-ai-ai](https://github.com/forkless/ai-ai-ai)

- `1-init.ps1` — folder structure, GPU detection, config files
- `2-deps.ps1` — install Git, Python, Ollama, FFmpeg
- `3-comfyui.ps1` — ComfyUI clone, venv, GPU backend, model paths
- `ai.ps1` — daily control panel (start/stop/status/doctor/install)

Grab the [latest release](https://github.com/forkless/ai-ai-ai/releases) or clone the repo directly.
