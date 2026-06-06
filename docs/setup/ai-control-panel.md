← [Setup](../)

# Ai, ai, ai! Control Panel v0.1.1

The `ai` command is your daily driver for managing services, checking status, and keeping things clean.

## Setup

Run `ai setup path` once to make `ai` available from any folder. See the [command docs](#ai-setup-path) below.

## Commands

### ai start &lt;service&gt;

Start a service in the background:

```powershell
ai start all
ai start ollama
ai start comfyui
ai start openwebui
```

`ai start all` starts every installed service at once.

Ollama runs as a hidden process. ComfyUI launches in a hidden PowerShell window. Both detach from your terminal.

Each start regenerates the launcher script from the current `ports.json` settings, so changing ports with `ai setup ports` takes effect on the next start - no manual edits needed.

Start and stop commands are quiet on success - no output means it worked. If a service fails to start (the port isn't responding after the usual wait), the last few lines from the log are shown so you can see what went wrong.

On every start, log files are rotated: the previous session's log is archived to `AI_CACHE\logs\archive\` and a fresh log file is created.

### ai stop &lt;service&gt;

Stop a running service:

```powershell
ai stop all
ai stop ollama
ai stop comfyui
```

### ai restart &lt;service&gt;

Stop and start a service in one command:

```powershell
ai restart all
ai restart ollama
ai restart comfyui
ai restart openwebui
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

The status dashboard only tracks tools installed through `ai install <app>`. Manually installed tools outside the AI stack folder won't show up - which is intentional, no false positives from random processes on your machine.

Example output:

```
┌──────────────┬─────────┬────────┐
│ Service      │ Status  │ Port   │
├──────────────┼─────────┼────────┤
│ Ollama       │ Up      │ 11434  │
│ ComfyUI      │ Up      │ 8188   │
│ OpenWebUI    │ Up      │ 3000   │
└──────────────┴─────────┴────────┘

CPU:  8%
RAM:  19.4/31.9 GB (61%)
GPU:  15% | VRAM: 2.4/16.0 GB

  Models:
    LLMs:        2
    Diffusion:   0
    VAEs:        0
```

### ai install &lt;app&gt;

Install or update an application:

```powershell
ai install all
ai install comfyui
ai install comfyui-manager
ai install ollama
ai install openwebui
```

`ai install all` installs or updates everything at once.

Before installing or updating, the script stops any running service first. This prevents file lock errors and avoids corrupting an in-use installation. If a service can't be stopped within 10 seconds, the script exits with an error rather than proceeding. Once the update finishes, you start it again with `ai start <service>`.

Re-running is safe - it pulls updates, preserves the venv, and regenerates config files.

ComfyUI detects your GPU generation and selects the right engine automatically. On AMD RDNA2+ cards (RX 6000/7000/9000) it uses ROCm (AMD's native GPU platform) with Python 3.12. On RDNA1 (RX 5000) it uses DirectML, since ROCm isn't available for that generation. You can override the choice:

```powershell
ai install comfyui                          # Auto-detect - ROCm on RDNA2+, DirectML on RDNA1
ai install comfyui -Backend directml        # Force DirectML
```

Each backend gets its own Python virtual environment - `venv_rocm` for ROCm, `venv` for DirectML. Switch between them by re-running the install with the other flag; both environments coexist. On re-install, the script remembers your previous choice from config - no re-prompting.

ComfyUI-Manager adds a UI for browsing and installing custom nodes - after installing and restarting ComfyUI, **refresh the browser tab once** to see the manager toolbar. Open Web UI installs in `AI_CORE\Apps\open-webui` and connects to your local Ollama instance automatically. The first install takes a few minutes - it downloads FastAPI, aiohttp, and other web server dependencies.

### ai remove &lt;app&gt;

Remove an installed application:

```powershell
ai remove comfyui
ai remove comfyui-manager
ai remove ollama
ai remove openwebui
```

This removes the application folder, its venv, and config. Models in AI_VAULT are preserved. Removing ComfyUI-Manager is useful if a custom node causes issues - it's a simple folder delete.

### ai doctor

Full system diagnostics - checks Git, Python versions, Ollama, FFmpeg, architecture, ComfyUI, Open Web UI, ROCm availability (when `venv_rocm` is present), model bindings, installed models, and environment variables.

```powershell
ai doctor
```

Example output:

```
┌──────────────────────┬──────────────────────────────┐
│ Stack                │ v0.1.1 (AMD)                   │
│ Path                 │ D:\AI                        │
├──────────────────────┼──────────────────────────────┤
│ Git                  │ 2.54.0                       │
│ Python 3.10          │ 3.10.11                      │
│ Python 3.11          │ 3.11.9                       │
│ Ollama               │ 0.30.2                       │
│ ComfyUI              │ 0.24.0                       │
│ Open Web UI          │ 0.9.6                        │
│ FFmpeg               │ 8.1.1                        │
├──────────────────────┼──────────────────────────────┤
│ Model bindings       │ OK                           │
│ Models               │ 2 LLM(s), 0 diffusion        │
│ Environment vars     │ OK                           │
└──────────────────────┴──────────────────────────────┘
```

### ai list

Lists all installed models grouped by category (LLM, Diffusion, VAE, LoRAs, etc.):

```powershell
ai list
```

### ai watch &lt;service&gt;

View a service's live log output:

```powershell
ai watch comfyui
ai watch ollama
ai watch openwebui
```

Shows real-time log lines from `AI_CACHE\logs\<service>.log`. Press Ctrl+C to stop.

Service output is written to log files automatically on every start. Logs from previous days are zipped and archived; archives older than 7 days are cleaned up.

### ai clean cache

Empties all temporary data from AI_CACHE - including archived logs:

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

- `OLLAMA_MODELS` - should point to `AI_VAULT\models\llm`
- `HF_HOME` - should point to `AI_CACHE\huggingface`
- `TORCH_HOME` - should point to `AI_CACHE\torch`

If any variable is missing or wrong, it offers to fix it. Skipping any variable causes the check to fail - this prevents accidental misconfiguration.

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

Prompts for each service's port and listen address. Defaults are created during initialization: Ollama 11434 (0.0.0.0), ComfyUI 8188 (0.0.0.0), Open Web UI 3000 (0.0.0.0). Settings save to `AI_CONFIG\ports.json`. Restart services after changing.

> **`0.0.0.0` binds to all local interfaces** - services accept connections from `localhost`, `127.0.0.1`, and any device on your home network. This is not a public exposure by itself, but if you forward ports on your router or disable your firewall, these services become reachable from the internet. Use [WireGuard](../networking/index.md#wireguard-in-case-your-router-supports-it) (or [Tailscale](../networking/index.md#tailscale) if your router doesn't support it) for remote access instead of opening ports.

The port config is created automatically by `1-init.ps1` with the defaults. You only need `ai setup ports` if you want different ports - for example, if 8188 is already in use by another application.

### ai help

Shows the full command list:

```powershell
ai help
```
