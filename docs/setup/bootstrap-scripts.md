# Ai, ai, ai! Bootstrap v1.1

Three scripts automate the whole setup — folders, software, and ComfyUI. A fourth script (`ai`) handles daily tasks like starting services and checking what's running.

Source code lives at [github.com/forkless/ai-ai-ai](https://github.com/forkless/ai-ai-ai).

**Download the scripts — pick one:**

```powershell
# Option A: Clone the repo (keeps auto-updating with git pull)
git clone https://github.com/forkless/ai-ai-ai.git
cd ai-ai-ai

# Option B: Download the latest release zip, then extract
# Visit https://github.com/forkless/ai-ai-ai/releases
# Download Ai.ai.ai.Bootstrap.v1.1.zip, extract somewhere, cd into scripts/
```

After downloading, unblock the scripts if you used the zip:

```powershell
Get-ChildItem *.ps1 | Unblock-File
```

## What You'll Need

- **Windows 10 or 11**
- **PowerShell** — comes with Windows, no install needed
- **Admin rights** — the script installs software, so it needs permission to do that
- **One-time setting** — run this so PowerShell trusts the scripts:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

## What You're Building

The scripts set up a clean folder structure with 6 sections, each with its own job:

```
AI_CONFIG     → settings, which models you have
AI_CORE       → the apps that do the work (ComfyUI, Ollama)
AI_VAULT      → your models, stored once, shared by everything
AI_WORKSPACE  → your images, prompts, generated files
AI_TOOLS      → helper scripts and utilities
AI_CACHE      → temporary downloads (can delete anytime)
```

The key idea: your models live in one place. Install, reinstall, or remove any AI tool without losing a single model. Want the full logic behind this? See **[Organize Your AI Folders](organize-your-ai-folders.md)**.

## First-Time Download

PowerShell blocks scripts from the internet by default. If you get an error, unblock them with:

```powershell
Get-ChildItem *.ps1 | Unblock-File
```

Run that once, then you're good.

## The Scripts

| Script | What it does |
|--------|-------------|
| **[1-init.ps1](https://github.com/forkless/ai-ai-ai/blob/main/scripts/1-init.ps1)** | Lays the foundation. Creates the full folder structure (37 directories across 6 layers), detects NVIDIA or AMD GPU, sets up symbolic links from `AI_CORE\_bindings` to `AI_VAULT`, and writes three config files: `system_config.json`, `model_registry.json`, `ports.json`. **Does not install anything.** Needs admin rights or Developer Mode for the symbolic links. |
| **[2-deps.ps1](https://github.com/forkless/ai-ai-ai/blob/main/scripts/2-deps.ps1)** | Installs system software — Git, Python 3.10, Python 3.11, Ollama, and FFmpeg — all through winget. Then sets three environment variables (`OLLAMA_MODELS`, `HF_HOME`, `TORCH_HOME`) to keep models and caches in their proper folders. **Requires admin rights.** |
| **[3-comfyui.ps1](https://github.com/forkless/ai-ai-ai/blob/main/scripts/3-comfyui.ps1)** | Downloads ComfyUI into `AI_CORE\Apps`, creates an isolated Python 3.11 virtual environment, installs GPU-appropriate PyTorch (CUDA for NVIDIA, DirectML for AMD — with a workaround for AMD's CUDA DLL crashes), writes `extra_model_paths.yaml` mapping 11 model subdirectories to your vault, and generates a launcher script that reads the port and listen address from `ports.json`. |
| **[ai.ps1](https://github.com/forkless/ai-ai-ai/blob/main/scripts/ai.ps1)** | Your daily driver — start, stop, restart services; check status with a compact dashboard; run full diagnostics (`ai doctor`); list installed models; clear cache; install or remove apps; configure ports and environment variables. |

## Run Order

Scripts must run in this order. Each one prepares something the next one needs.

```
1. 1-init.ps1         create folders + links + config
       ↓
   Restart PowerShell — lets it find newly installed tools
       ↓
2. 2-deps.ps1         install Git, Python, Ollama, FFmpeg
   (requires admin rights — right-click PowerShell and run as Administrator)
       ↓
   Restart PowerShell — lets it find newly installed tools, loads env vars
       ↓
3. 3-comfyui.ps1      install ComfyUI, set up model paths, create launcher
```

**Why restart?** When you install software, Windows adds it to your system PATH so you can run it from anywhere. But currently open windows don't see the change. Close and reopen, and everything works. The restart after step 2 also loads the new environment variables (`OLLAMA_MODELS`, `HF_HOME`, `TORCH_HOME`) — without them, step 3 will fail its environment check.

## Environment Variables (What They Are)

Think of these as shortcuts that tell your tools where to put things. The scripts set them automatically, but here's what they control:

| Shortcut | Points to | What it does |
|----------|-----------|-------------|
| `OLLAMA_MODELS` | `AI_VAULT\models\llm` | Tells Ollama to store models in the vault |
| `HF_HOME` | `AI_CACHE\huggingface` | Keeps Hugging Face downloads in the cache folder |
| `TORCH_HOME` | `AI_CACHE\torch` | Keeps PyTorch downloads in the cache folder |

If something seems off later, run `ai setup env` to check and fix them.

## A Few Things to Know

- **GPU detection**: The scripts check what GPU you have. NVIDIA cards get CUDA, AMD cards get DirectML. You don't need to pick.
- **Safe to re-run**: Running a script again won't break anything. It skips what's already there, creates what's missing.
- **Root path**: You set your install location once in `1-init.ps1`. The other scripts read it from a config file — no need to type it again.

## Port Configuration

Each service has a default port and listen address set during initialization:

| Service | Default Port | Default Listen Address |
|---------|-------------|----------------------|
| Ollama | 11434 | 0.0.0.0 |
| ComfyUI | 8188 | 0.0.0.0 |
| Open Web UI | 3000 | 0.0.0.0 |

Change ports anytime with `ai setup ports`. Settings save to `AI_CONFIG\ports.json` with a `listen` field controlling which network interface each service binds to. Restart the service after changing.

> **Default is `0.0.0.0` for convenience** — accepts `http://localhost`, `http://127.0.0.1`, `http://192.168.0.x`, and any other local network address. This makes it easy to reach services from other devices on your home network. It **does not** mean your services are exposed to the public internet — no port forwarding, no cloud. But if you do open ports on your router, those services become reachable from outside. Review your firewall settings and avoid forwarding AI tool ports to the open web. For remote access, see [WireGuard](../networking/index.md#wireguard-in-case-your-router-supports-it) (or [Tailscale](../networking/index.md#tailscale) if your router doesn't support it). For nice local URLs, see [Reverse Proxy](../networking/index.md#reverse-proxy-for-nice-urls).

## Install Summary

When `2-deps.ps1` finishes, it prints a summary like this:

```
Install Summary
  Git: Skipped (already up to date)
  Python 3.10: Skipped (already up to date)
  Ollama: Skipped (already up to date)
  FFmpeg: Skipped (already up to date)
```

**"Skipped" is normal** — it means the tool was already installed and no newer version was available. You only see "Installed" on the very first run.

**Pip notice:** You may see `[notice] A new release of pip is available` during ComfyUI setup. That's just pip telling you a newer version exists. The version that comes with Python 3.11 works fine — you can ignore it.

## Launcher Scripts

After setup, `AI_TOOLS\` contains launcher scripts for each service:

| Script | Created by | Starts |
|--------|-----------|--------|
| `launch_comfyui.ps1` | `3-comfyui.ps1` | ComfyUI with correct GPU backend, port, and listen address from `ports.json` |
| `launch_ollama.ps1` | `ai start ollama` (auto-generated) | Ollama in background |
| `launch_openwebui.ps1` | `ai start openwebui` (auto-generated) | Open Web UI |

The ComfyUI launcher is generated during setup. The others are created the first time you run `ai start <service>`. All three read the current port and listen address from `ports.json`, so changing ports with `ai setup ports` takes effect on the next launch without re-installing anything.

You can also run any launcher directly from `AI_TOOLS\`.

**Note:** The bootstrap scripts install and configure everything, but don't start the services. You need to launch them manually when you want to use them.

## After Everything Runs

Open a fresh PowerShell window and try:

| Command | What it does |
|---------|-------------|
| `ai start all` | Starts all services |
| `ai stop all` | Stops all services |
| `ai restart all` | Restarts all services |
| `ai status` | Compact dashboard — running services, ports, model counts |
| `ai status ollama` | Check a single service (ollama, comfyui, or openwebui) |
| `ai doctor` | Full system diagnostics (Git, Python, services, env, model bindings) |
| `ai list` | Lists every installed model, grouped by category |
| `ai install all` | Install or update everything at once (stops services first to prevent file locks and upgrade corruption) |
| `ai install comfyui-manager` | Adds custom node browser to ComfyUI |
| `ai install openwebui` | Installs Open Web UI for Ollama |
| `ai remove comfyui` | Remove an installed app (keeps models in vault) |
| `ai setup ports` | Change service ports and listen address |
| `ai setup env` | Check and fix environment variables |
| `ai setup path` | Add `ai` to your PATH so it works from any folder |
| `ai watch comfyui` | Live-tail service logs (comfyui, ollama, openwebui) |
| `ai clean cache` | Free up space by emptying AI_CACHE and archived logs |
| `ai help` | Show the full command reference |
| `ollama pull llama3` | Downloads a model (lands in the vault) |
