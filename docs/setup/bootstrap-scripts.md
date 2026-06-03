# Bootstrap Scripts

Three PowerShell scripts automate the architecture deployment and a control panel manages everything day-to-day. All scripts are available in the `scripts/` folder of this repository or in the [latest release zip](https://github.com/forkless/knowledge-base/releases/tag/v0.1.0).

## Prerequisites

- Windows 10 or 11
- PowerShell 5.1 or later
- Administrator rights (for winget installs and symbolic links)
- Execution policy allowing scripts: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

## What You're Building

The scripts create a modular AI environment with 6 independent layers:

```
AI_CONFIG     → configuration and model registry
AI_CORE       → runtimes (ComfyUI, Ollama, LM Studio)
AI_VAULT      → permanent models and datasets
AI_WORKSPACE  → inputs, outputs, workflows
AI_TOOLS      → scripts, converters, utilities
AI_CACHE      → temporary downloads (safe to delete)
```

Models live in AI_VAULT, shared across all tools through symbolic links. No duplication, no scattered folders. Reinstall any tool without losing a single model.

See **[Organize Your AI Folders](organize-your-ai-folders.md)** for the full architecture breakdown and design rationale.

## First-Time Download

PowerShell blocks scripts downloaded from the internet — if you get a "not digitally signed" error, unblock them first:

```powershell
Get-ChildItem *.ps1 | Unblock-File
```

This removes the NTFS download marker without modifying the script content. Only needed once.

## Script Overview

| Script | Purpose |
|--------|---------|
| **[1-init.ps1](https://github.com/forkless/knowledge-base/blob/master/scripts/1-init.ps1)** | Creates folder structure, symbolic links, initial config files. Detects GPU. No software install. |
| **[2-deps.ps1](https://github.com/forkless/knowledge-base/blob/master/scripts/2-deps.ps1)** | Installs Git, Python 3.10, Python 3.11, and Ollama via winget. Auto-configures environment variables. |
| **[3-comfyui.ps1](https://github.com/forkless/knowledge-base/blob/master/scripts/3-comfyui.ps1)** | Clones ComfyUI, creates venv, installs dependencies, configures model paths, generates launcher. |
| **[ai.ps1](https://github.com/forkless/knowledge-base/blob/master/scripts/ai.ps1)** | Unified control panel: install, start/stop/status, models, cache, env checks. |

## Deployment Order

```
1. 1-init.ps1         create folders + bindings + config
       ↓
   Restart PowerShell — PATH updated with new tools
       ↓
2. 2-deps.ps1         install Git, Python, Ollama
       ↓
   Restart PowerShell — new tools added to PATH
       ↓
3. 3-comfyui.ps1      clone ComfyUI, venv, model paths
```

**Why restart between scripts:** Windows updates the system PATH when software is installed, but existing PowerShell windows don't reload it. Skipping the restart means `git`, `py`, and `ollama` commands won't be found.

## Environment Variables

Configured automatically by `2-deps.ps1`, but you can verify or fix them with `ai setup env`.

| Variable | Points to | Purpose |
|----------|-----------|---------|
| `OLLAMA_MODELS` | `AI_VAULT\models\llm` | Models land in the vault |
| `HF_HOME` | `AI_CACHE\huggingface` | Cache stays out of vault |
| `TORCH_HOME` | `AI_CACHE\torch` | Cache stays out of vault |

All three must be set before pulling models or running AI tools — the scripts handle this.

## Design Notes

- **GPU detection**: Scripts detect NVIDIA vs AMD via WMI. NVIDIA gets CUDA PyTorch, AMD gets DirectML.
- **Idempotent**: Re-running scripts is safe — folders are skipped if they exist, venv is preserved on re-run.
- **Root path**: Set once by `1-init.ps1`, stored in `system_config.json`. Other scripts read from there.
- **Backward compatible**: The old long-named scripts (`Initialize-AIArchitecture.ps1`, etc.) still work but are deprecated.

## After Deployment

Use `ai start ollama` and `ai start comfyui` to launch services. Run `ai status` to verify everything is healthy. Pull models with `ollama pull` and they'll land in the vault automatically.
