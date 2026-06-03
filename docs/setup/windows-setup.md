← [Setup](../)

# Windows Setup Guide

Everything on this page is automated by the **[Bootstrap Scripts](bootstrap-scripts.md)**. This guide explains what the scripts do behind the scenes, step by step, so you understand the process whether you use the automation or follow along manually.

## What the Bootstrap Scripts Do

The scripts run in three phases. Each builds on the previous one.

### Phase 1: Folders and Structure

```
1-init.ps1
```

- Creates the D:\AI\ folder with all 6 layers (AI_CONFIG, AI_CORE, AI_VAULT, AI_WORKSPACE, AI_TOOLS, AI_CACHE)
- Detects your GPU type (NVIDIA or AMD) and writes it to `system_config.json`
- Creates symbolic links so AI tools find models in the vault
- Generates starter config files (`system_config.json`, `model_registry.json`)

No software is installed in this phase.

### Phase 2: Dependencies

```
2-deps.ps1
```

Installs everything needed to run AI tools:

| Tool | Why |
|------|-----|
| Git | Required to download ComfyUI and custom nodes |
| Python 3.11 | Main runtime for ComfyUI and most AI tools |
| Python 3.10 | Fallback for tools that haven't updated to 3.11 |
| Ollama | Runs local LLMs as a background service |

Also sets environment variables so models and caches go to the right places instead of scattering across your drive.

**After this phase, restart PowerShell** — newly installed tools won't be found otherwise.

### Phase 3: ComfyUI

```
3-comfyui.ps1
```

- Downloads ComfyUI into `AI_CORE\Apps`
- Creates a Python 3.11 virtual environment (isolated, won't conflict with other tools)
- Installs PyTorch with the correct GPU backend — CUDA for NVIDIA, DirectML for AMD
- Generates `extra_model_paths.yaml` so ComfyUI finds models in the vault
- Creates a launcher script at `AI_TOOLS\launch_comfyui.ps1`

## Running the Scripts

```powershell
Unblock-File *.ps1          # only needed once after download
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser   # only needed once
.\1-init.ps1                # step 1: folders + config
# restart PowerShell
.\2-deps.ps1                # step 2: Git, Python, Ollama
# restart PowerShell
.\3-comfyui.ps1             # step 3: ComfyUI
```

## Installing Manually Without Scripts

If you prefer not to use the scripts:

```powershell
winget install Git.Git
winget install Python.Python.3.10
winget install Python.Python.3.11
winget install Ollama.Ollama
```

Then follow the **[Organize Your AI Folders](organize-your-ai-folders.md)** guide to create the folder structure by hand.

## Common Pitfalls

- **Command not found?** Close PowerShell and open a fresh window
- **Winget outdated?** Download installers directly from python.org or ollama.com
- **Symlinks fail?** Run PowerShell as Administrator, or enable Developer Mode in Windows Settings
- **Venv activation blocked?** Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` first
