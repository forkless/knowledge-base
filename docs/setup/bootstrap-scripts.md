# Bootstrap Scripts

Three PowerShell scripts automate the architecture deployment. Each handles one responsibility — no overlap.

## Prerequisites

- Windows 10 or 11
- PowerShell 5.1 or later
- Administrator rights (for winget installs and symbolic links)
- Execution policy allowing scripts: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`

Run scripts in order. Restart PowerShell between scripts as noted.

## Initialize-AIArchitecture.ps1

Creates the full folder structure, symbolic links, and initial config files. Does not install any software.

```powershell
# Run this first
.\Initialize-AIArchitecture.ps1
```

Prompts for the install path. Defaults to `D:\AI` if left blank.

**What it creates:**

- Full 6-layer directory tree (AI_CONFIG, AI_CORE, AI_VAULT, AI_WORKSPACE, AI_TOOLS, AI_CACHE)
- AI_CORE organized into Apps, Services, Environments, and `_bindings`
- AI_VAULT with subdirectories for checkpoints, LoRAs, VAEs, ControlNet
- Symbolic links at `AI_CORE\_bindings` pointing to `AI_VAULT\models`
- `system_config.json` with architecture version, root path, platform
- `model_registry.json` with an empty model list (populated manually or by future tooling)

**Notes:**

- Symbolic links require admin rights or Developer Mode enabled on Windows 10/11
- Existing folders are skipped — the script is idempotent and safe to re-run
- The `gpu` field in system_config defaults to `"unknown"` — update it to `"amd"` or `"nvidia"` after install

## Install-AIPrerequisites.ps1

Installs system-wide dependencies via winget. Does not create any folders.

```powershell
# Run second, after architecture is initialized
.\Install-AIPrerequisites.ps1
```

**What it installs:**

| Package | Version | Purpose |
|---------|---------|---------|
| Git | Latest | Cloning ComfyUI and custom nodes |
| Python 3.10 | Latest | Legacy compatibility runtime |
| Python 3.11 | Latest | Primary AI runtime |
| Ollama | Latest | Local LLM server |

**Important — read this before running:**

- Requires administrator rights (winget installs system packages)
- After installation, **close all PowerShell windows and open a new one** before proceeding
- Windows updates PATH immediately, but existing terminals do not reload it
- Verify with: `py -0`, `git --version`, `ollama --version`

## Install-ComfyUI.ps1

Clones ComfyUI into `AI_CORE\Apps`, creates a Python virtual environment, installs dependencies, configures model paths, and generates a launcher script.

```powershell
# Run third, after prerequisites are installed and terminal is refreshed
.\Install-ComfyUI.ps1
```

Prompts for the AI root path (must match what was entered for Initialize-AIArchitecture).

**What it does:**

1. Clones the ComfyUI repository into `AI_CORE\Apps\ComfyUI`
2. Creates a Python 3.11 virtual environment inside the ComfyUI folder
3. Activates the venv and installs requirements from `requirements.txt`
4. Generates `extra_model_paths.yaml` pointing all model types to AI_VAULT
5. Creates a launcher at `AI_TOOLS\launch_comfyui.ps1`

**Generated extra_model_paths.yaml:**

```yaml
checkpoints: D:\AI\AI_VAULT\models\diffusion\checkpoints
loras: D:\AI\AI_VAULT\models\diffusion\loras
vae: D:\AI\AI_VAULT\models\diffusion\vae
controlnet: D:\AI\AI_VAULT\models\diffusion\controlnet
embeddings: D:\AI\AI_VAULT\models\embeddings
```

**Generated launcher (AI_TOOLS\launch_comfyui.ps1):**

```powershell
Set-Location "D:\AI\AI_CORE\Apps\ComfyUI"
.\venv\Scripts\Activate.ps1
python main.py --temp-directory "D:\AI\AI_CACHE\comfyui_temp"
```

**Notes:**

- If the ComfyUI folder already exists, the clone step is skipped
- The virtual environment is always recreated (existing venv is replaced)
- If PowerShell execution policy blocks `.\venv\Scripts\Activate.ps1`, run: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
- The launcher embeds the absolute path at creation time — if the AI root moves, regenerate it

## Deployment Order

```
Initialize-AIArchitecture.ps1           Step 1 — folders + bindings
    ↓
Restart PowerShell
    ↓
Install-AIPrerequisites.ps1             Step 2 — Git, Python, Ollama
    ↓
Restart PowerShell
    ↓
Install-ComfyUI.ps1                     Step 3 — ComfyUI + model paths
```

## Script Locations

The scripts themselves live wherever you keep your tools. After architecture initialization, `AI_TOOLS\scripts\` is the natural home for them.
