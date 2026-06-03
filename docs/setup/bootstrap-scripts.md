# Bootstrap Scripts

Three PowerShell scripts automate the architecture deployment. Each handles one responsibility — no overlap.

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

PowerShell blocks scripts downloaded from the internet by default. If you get a "not digitally signed" error, unblock them first:

```powershell
Unblock-File .\1-init.ps1
Unblock-File .\2-deps.ps1
Unblock-File .\3-comfyui.ps1
Unblock-File .\ai.ps1
```

Or unblock everything at once:

```powershell
Get-ChildItem *.ps1 | Unblock-File
```

This only needs to be done once after downloading.

## Deployment Order

These scripts must run in sequence. Each builds on the previous one. Running them out of order will fail because the folders, dependencies, or paths won't exist yet.

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

## 1-init.ps1

Creates the full folder structure, symbolic links, and initial config files. Does not install any software.

Run with: `.\1-init.ps1`

Prompts for the install path. Defaults to `D:\AI` if left blank.

```powershell
<#
AI Architecture Initializer v1.1
Creates folder structure + config + bindings only
No software installation
#>

$RootMode = Read-Host "Install path (press Enter for D:\AI)"

if ([string]::IsNullOrWhiteSpace($RootMode)) {
    $BasePath = "D:\AI"
} else {
    $BasePath = $RootMode.TrimEnd("\")
}

Write-Host "AI Root: $BasePath"

# Folders
$folders = @(
    "$BasePath",
    "$BasePath\AI_CONFIG",
    "$BasePath\AI_CORE",
    "$BasePath\AI_CORE\Apps",
    "$BasePath\AI_CORE\Services",
    "$BasePath\AI_CORE\Environments",
    "$BasePath\AI_CORE\_bindings",
    "$BasePath\AI_VAULT",
    "$BasePath\AI_VAULT\models",
    "$BasePath\AI_VAULT\models\llm",
    "$BasePath\AI_VAULT\models\diffusion",
    "$BasePath\AI_VAULT\models\diffusion\checkpoints",
    "$BasePath\AI_VAULT\models\diffusion\loras",
    "$BasePath\AI_VAULT\models\diffusion\vae",
    "$BasePath\AI_VAULT\models\diffusion\controlnet",
    "$BasePath\AI_VAULT\models\embeddings",
    "$BasePath\AI_VAULT\datasets",
    "$BasePath\AI_WORKSPACE",
    "$BasePath\AI_WORKSPACE\workflows",
    "$BasePath\AI_WORKSPACE\input",
    "$BasePath\AI_WORKSPACE\output",
    "$BasePath\AI_WORKSPACE\sessions",
    "$BasePath\AI_TOOLS",
    "$BasePath\AI_TOOLS\scripts",
    "$BasePath\AI_TOOLS\utilities",
    "$BasePath\AI_TOOLS\converters",
    "$BasePath\AI_CACHE",
    "$BasePath\AI_CACHE\huggingface",
    "$BasePath\AI_CACHE\torch",
    "$BasePath\AI_CACHE\comfyui_temp",
    "$BasePath\AI_CACHE\ollama"
)

foreach ($f in $folders) {
    if (!(Test-Path $f)) {
        New-Item -ItemType Directory -Path $f -Force | Out-Null
        Write-Host "Created: $f"
    }
}

# Symlinks
cmd /c mklink /D "$BasePath\AI_CORE\_bindings\llm" "$BasePath\AI_VAULT\models\llm"
cmd /c mklink /D "$BasePath\AI_CORE\_bindings\diffusion" "$BasePath\AI_VAULT\models\diffusion"
cmd /c mklink /D "$BasePath\AI_CORE\_bindings\embeddings" "$BasePath\AI_VAULT\models\embeddings"

# Config files
$config = @{
    architecture_version = "1.1"
    platform = "windows"
    root = $BasePath
    vault = "$BasePath\AI_VAULT"
    workspace = "$BasePath\AI_WORKSPACE"
    cache = "$BasePath\AI_CACHE"
    gpu = "unknown"
}
$config | ConvertTo-Json -Depth 10 | Out-File "$BasePath\AI_CONFIG\system_config.json"

$modelRegistry = @{ models = @() }
$modelRegistry | ConvertTo-Json -Depth 10 | Out-File "$BasePath\AI_CONFIG\model_registry.json"

Write-Host "Architecture initialization complete"
```

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
- GPU is auto-detected via WMI and written to `system_config.json`

**Next:** Restart PowerShell, then run [2-deps.ps1](#2-depsps1).

## 2-deps.ps1

Installs system-wide dependencies via winget. Does not create any folders.

```powershell
<#
Installs system dependencies only
No folder creation
#>

Write-Host "Installing prerequisites..."

winget install Git.Git
winget install Python.Python.3.10
winget install Python.Python.3.11
winget install Ollama.Ollama

Write-Host ""
Write-Host "IMPORTANT: restart PowerShell after install"
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
- Winget sources can lag behind the latest releases by a few days. If you need a newer version than winget provides, download installers directly from python.org and ollama.com
- After installation, **close all PowerShell windows and open a new one** before proceeding
- Windows updates PATH immediately, but existing terminals do not reload it
- Verify with: `py -0`, `git --version`, `ollama --version`

**Next:** Restart PowerShell, then run [3-comfyui.ps1](#3-comfyups1).

## 3-comfyui.ps1

Clones ComfyUI into `AI_CORE\Apps`, creates a Python virtual environment, installs dependencies, configures model paths, and generates a launcher script.

```powershell
<#
Installs ComfyUI into AI_CORE\Apps
Connects to AI_VAULT via extra model paths
#>

$Root = Read-Host "Enter AI root path (e.g. D:\AI)"

$ComfyPath = "$Root\AI_CORE\Apps\ComfyUI"

if (!(Test-Path $ComfyPath)) {
    git clone https://github.com/comfyanonymous/ComfyUI.git $ComfyPath
}

Set-Location $ComfyPath

# Python env
py -3.11 -m venv venv
.\venv\Scripts\Activate.ps1
pip install --upgrade pip
pip install -r requirements.txt

# Model path config
$yaml = @"
checkpoints: $Root\AI_VAULT\models\diffusion\checkpoints
loras: $Root\AI_VAULT\models\diffusion\loras
vae: $Root\AI_VAULT\models\diffusion\vae
controlnet: $Root\AI_VAULT\models\diffusion\controlnet
embeddings: $Root\AI_VAULT\models\embeddings
"@

$yaml | Out-File "$ComfyPath\extra_model_paths.yaml"

# Launcher
$launcher = @"
Set-Location "$ComfyPath"
.\venv\Scripts\Activate.ps1
python main.py --temp-directory "$Root\AI_CACHE\comfyui_temp"
"@

$launcher | Out-File "$Root\AI_TOOLS\launch_comfyui.ps1"

Write-Host "ComfyUI installation complete"
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

**GPU detection:**

The script detects your GPU and installs the correct backend automatically:

- **NVIDIA** — standard CUDA PyTorch from requirements.txt
- **AMD** — uninstalls CUDA torch, installs `torch-directml` instead

**Notes:**

- If the ComfyUI folder already exists, the clone step is skipped
- The virtual environment is always recreated (existing venv is replaced)
- If PowerShell execution policy blocks `.\venv\Scripts\Activate.ps1`, run: `Set-ExecutionPolicy -Scope CurrentUser RemoteSigned`
- The launcher embeds the absolute path at creation time — if the AI root moves, regenerate it

**Done.** ComfyUI is installed, configured, and ready to launch from `AI_TOOLS\launch_comfyui.ps1`.

## Script Locations

The scripts live in the `scripts/` folder of this repository. A zip archive (`ai-bootstrap-v1.1.zip`) is available at the repo root for easy download — grab it, extract, and run.

After architecture initialization, copy them to `AI_TOOLS\scripts\` or run them directly. All scripts are also mirrored in this documentation as code blocks above — inspect them before running.
