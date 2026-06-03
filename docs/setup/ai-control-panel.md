← [Setup](../)

# AI Control Panel

The `ai` command is a unified CLI for managing the entire AI architecture. Instead of running individual bootstrap scripts, you use one entry point.

## Setup

The script is at `scripts/ai.ps1` in this repository. Two ways to use it:

**From the repo folder:**

```powershell
.\scripts\ai.ps1 status
```

**Add to your PATH (recommended):**

```powershell
# Add AI_TOOLS to your PATH so 'ai' is always available
$env:Path += ";D:\AI\AI_TOOLS"
# Then copy the script there
copy scripts\ai.ps1 D:\AI\AI_TOOLS\ai.ps1
# Now from any folder:
ai status
```

## Commands

### ai install comfyui

Installs or updates ComfyUI into `AI_CORE\Apps`. If the folder already exists, it pulls the latest changes instead of re-cloning.

```powershell
ai install comfyui
```

Detects your GPU and installs the correct backend:

- **NVIDIA** — standard CUDA PyTorch from requirements.txt
- **AMD** — uninstalls CUDA torch, installs `torch-directml` instead

Also updates `system_config.json` with the detected GPU type so other tools can reference it.

Creates:
- Python 3.11 virtual environment
- `extra_model_paths.yaml` pointing to AI_VAULT
- Launcher script at `AI_TOOLS\launch_comfyui.ps1`

### ai install ollama

Installs Ollama via winget. After installation, the script reminds you to restart PowerShell and set the `OLLAMA_MODELS` environment variable.

```powershell
ai install ollama
```

### ai status

Health check for the entire architecture. Reports:

- Whether each layer folder exists (CONFIG, CORE, VAULT, WORKSPACE, TOOLS, CACHE)
- Architecture version and GPU type from system_config.json
- Whether ComfyUI is installed
- Whether Ollama is currently running
- Whether symbolic links are intact and where they point

```powershell
ai status
```

Example output:

```
System Status: D:\AI

  [OK]  AI_CONFIG
  [OK]  AI_CORE
  [OK]  AI_VAULT
  [OK]  AI_WORKSPACE
  [OK]  AI_TOOLS
  [OK]  AI_CACHE

  Config: v1.1 — unknown GPU

  [OK]  ComfyUI
  [--]  Ollama (not running)

  [OK]  _bindings\llm -> D:\AI\AI_VAULT\models\llm
  [OK]  _bindings\diffusion -> D:\AI\AI_VAULT\models\diffusion
  [OK]  _bindings\embeddings -> D:\AI\AI_VAULT\models\embeddings
```

### ai models list

Scans all model directories and counts files by type. Also reads the model registry if it has entries.

```powershell
ai models list
```

### ai clean cache

Empties all temporary data in AI_CACHE — Hugging Face cache, PyTorch cache, ComfyUI temp files, and Ollama temp data.

```powershell
ai clean cache
```

Shows how much space was freed.

### ai help

Displays the full command list.

```powershell
ai help
```

## Design

The control panel follows the same architecture principles:

- Each command has one responsibility
- Commands are idempotent where possible (re-running install updates rather than replacing)
- Status and models list are read-only
- Cache cleanup is explicitly named — no accidental data loss

As new tools are added to the architecture, new subcommands follow the same pattern: `ai install <name>`, `ai status` auto-detects, `ai models list` scans new directories.
