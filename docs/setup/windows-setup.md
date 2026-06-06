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
- Populates `AI_VAULT\models\diffusion\` with 12 subdirectories — checkpoints, diffusion_models, LoRAs, VAEs, ControlNet, UNet, text encoders, upscale models, IPAdapter, style models, CLIP vision, CLIP
- Detects your GPU type (NVIDIA or AMD) and writes it to `system_config.json`
- Creates symbolic links so AI tools find models in the vault
- Generates starter config files: `system_config.json`, `model_registry.json`, `ports.json` (with default ports and listen address)

No software is installed in this phase.

### Phase 2: Dependencies

```
2-deps.ps1
```

Installs the backend engine (Ollama) and all system tools the frontend apps need:

| Tool | Why |
|------|-----|
| Git | Required to download ComfyUI and custom nodes |
| Python 3.11 | Main runtime for ComfyUI and most AI tools |
| Python 3.10 | Fallback for tools that haven't updated to 3.11 |
| Python 3.12 | Required for ROCm ComfyUI backend (optional — AMD only) |
| Ollama | The backend LLM engine — runs as a service. Frontend apps (ComfyUI, Open Web UI) talk to it |
| FFmpeg | Video processing for AI workflows |

Also sets environment variables so models and caches go to the right places instead of scattering across your drive.

**After this phase, restart PowerShell** — newly installed tools won't be found otherwise.

### Phase 3: Applications

```
3-apps.ps1
```

- Verifies `OLLAMA_MODELS` points to the vault before proceeding (exits if wrong)
- Installs ComfyUI into `AI_CORE\Apps` (and optionally Open Web UI)
- Creates an isolated Python virtual environment — Python 3.12 on AMD RDNA2+ (for ROCm), Python 3.11 on RDNA1 or NVIDIA
- Installs PyTorch with the correct GPU engine — CUDA for NVIDIA, ROCm for AMD RDNA2+ (RX 6000/7000/9000), DirectML for AMD RDNA1 (RX 5000). Auto-detects your GPU generation and selects the appropriate backend
- To override, pass `-Backend directml` on AMD
- Generates `extra_model_paths.yaml` mapping 12 model subdirectories to your vault (uses a named config block `vault_config:`, not flat key-values)
- Creates launcher scripts at `AI_TOOLS\launch_comfyui.ps1` and `AI_TOOLS\launch_openwebui.ps1` that read port and listen address from `ports.json`

## Running the Scripts

```powershell
Unblock-File *.ps1          # only needed once after download
Set-ExecutionPolicy RemoteSigned -Scope CurrentUser   # only needed once
.\scripts\1-init.ps1        # step 1: folders + config
# restart PowerShell
.\scripts\2-deps.ps1        # step 2: Git, Python, Ollama, FFmpeg
# restart PowerShell
.\scripts\3-apps.ps1     # step 3: ComfyUI
.\scripts\ai.ps1 setup path # make ai available everywhere
```

## Installing Manually Without Scripts

If you prefer not to use the scripts:

```powershell
winget install Git.Git
winget install Python.Python.3.10
winget install Python.Python.3.11
winget install Python.Python.3.12
winget install Ollama.Ollama
```

Then follow the **[Organize Your AI Folders](organize-your-ai-folders.md)** guide to create the folder structure by hand.

## Reading the Install Summary

The script prints a summary after installing:

```
Install Summary
  Git: Skipped (already up to date)
  Python 3.10: Skipped (already up to date)
  Ollama: Skipped (already up to date)
  FFmpeg: Skipped (already up to date)
```

**"Skipped (already up to date)" is not an error.** It means the tool was already installed and no newer version was available. Only the first install shows "Installed" — re-runs will always show "Skipped."

## After Deps Install: Restart PowerShell

After `2-deps.ps1` installs Git, Python, Ollama, and FFmpeg, **restart PowerShell**. Existing windows won't see the new tools in PATH.

If `ai doctor` shows FFmpeg as missing even after install, a fresh terminal is likely all you need.

## Pip Version Notice

You might see this during ComfyUI install:

```
[notice] A new release of pip is available: 24.0 -> 26.1.2
```

This is a notification, not an error. The version that comes with Python 3.11 works perfectly. You can ignore it.

## Common Pitfalls

- **Command not found?** Close PowerShell and open a fresh window
- **Winget outdated?** Download installers directly from python.org or ollama.com
- **Symlinks fail?** Run PowerShell as Administrator, or enable Developer Mode in Windows Settings
- **Venv activation blocked?** Run `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned` first
