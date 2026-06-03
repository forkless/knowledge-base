← [Setup](../)

# Ai, ai, ai! Control Panel v1.1

The `ai` command is your daily driver for managing services, checking status, and keeping things clean.

## Setup

```powershell
# From the repo folder
.\scripts\ai.ps1 status

# Or copy to AI_TOOLS and add to PATH
copy scripts\ai.ps1 D:\AI\AI_TOOLS\ai.ps1
$env:Path += ";D:\AI\AI_TOOLS"
ai status
```

## Commands

### ai start &lt;service&gt;

Start a service in the background (no window):

```powershell
ai start ollama
ai start comfyui
```

Ollama runs as a hidden process. ComfyUI launches in a hidden PowerShell window. Both detach from your terminal.

### ai stop &lt;service&gt;

Stop a running service:

```powershell
ai stop ollama
ai stop comfyui
```

### ai restart &lt;service&gt;

Stop and start a service in one command:

```powershell
ai restart ollama
ai restart comfyui
```

Useful after config changes or if a service becomes unresponsive.

### ai status [service]

Full system health check:

```powershell
ai status
```

Or check a specific service:

```powershell
ai status ollama
ai status comfyui
```

The status dashboard only tracks tools installed through `ai install <app>`. Manually installed tools outside the AI stack folder won't show up — which is intentional, no false positives from random processes on your machine.

Example output:

```
System Status: D:\AI

  [OK]  AI_CONFIG
  [OK]  AI_CORE
  [OK]  AI_VAULT
  [OK]  AI_WORKSPACE
  [OK]  AI_TOOLS
  [OK]  AI_CACHE

  Config: v1.1 — amd GPU

  [OK]  ComfyUI
  [OK]  Ollama (running)

  [OK]  _bindings\llm -> D:\AI\AI_VAULT\models\llm
  [OK]  _bindings\diffusion -> D:\AI\AI_VAULT\models\diffusion
  [OK]  _bindings\embeddings -> D:\AI\AI_VAULT\models\embeddings
```

### ai install &lt;app&gt;

Install or update an application:

```powershell
ai install comfyui
ai install comfyui-manager
ai install ollama
ai install openwebui
```

Re-running is safe — it pulls updates, preserves the venv, and regenerates config files.

ComfyUI detected your GPU and sets up the right backend. ComfyUI-Manager adds a UI for browsing and installing custom nodes — after installing and restarting ComfyUI, **refresh the browser tab once** to see the manager toolbar. Open Web UI installs in `AI_CORE\Apps\open-webui` and connects to your local Ollama instance automatically. The first install takes a few minutes — it downloads FastAPI, aiohttp, and other web server dependencies.

### ai remove &lt;app&gt;

Remove an installed application:

```powershell
ai remove comfyui
ai remove ollama
```

This removes the application folder, its venv, and config. Models in AI_VAULT are preserved.

### ai models list

Counts all models by type using file scans:

```powershell
ai models list
```

### ai clean cache

Empties all temporary data from AI_CACHE:

```powershell
ai clean cache
```

Shows how much space was freed.

### ai setup env

Checks and fixes environment variables. Run this if paths seem wrong:

```powershell
ai setup env
```

Checks:

- `OLLAMA_MODELS` — should point to `AI_VAULT\models\llm`
- `HF_HOME` — should point to `AI_CACHE\huggingface`
- `TORCH_HOME` — should point to `AI_CACHE\torch`

If any variable is missing or wrong, it offers to fix it. Skipping any variable causes the check to fail — this prevents accidental misconfiguration.

### ai setup path

Makes `ai` available from any PowerShell window by adding AI_TOOLS to your user PATH:

```powershell
ai setup path
```

Copies itself to `AI_TOOLS\ai.ps1` and adds the folder to PATH. Works immediately in the current window and persists for all future windows.

### ai setup ports

Configure which ports each service uses:

```powershell
ai setup ports
```

Prompts for each service's port. Defaults: Ollama 11434, ComfyUI 8188, Open Web UI 3000. Settings save to `AI_CONFIG\ports.json`. Restart services after changing.

### ai help

Shows the full command list:

```powershell
ai help
```
