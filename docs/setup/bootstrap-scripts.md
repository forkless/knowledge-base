← [Setup](../)

# Ai, ai, ai! Bootstrap v0.1.1

Four scripts automate the whole setup — folders, software, and ComfyUI. A fourth script (`ai`) handles daily tasks like starting services and checking what's running.

Source code lives at [github.com/forkless/ai-ai-ai](https://github.com/forkless/ai-ai-ai).

## What You'll Need

- **Windows 10 or 11**
- **PowerShell** — comes with Windows, no install needed
- **Admin rights** — the dependency installer (`2-deps.ps1`) needs permission for winget installs
- **One-time setting** — run this so PowerShell trusts the scripts:

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

> **⚠️ AMD Radeon RX 7000/9000 users — stable driver baseline recommended.**
> These scripts were tested primarily on **Adrenalin 26.3.1**. They will run on newer drivers too, but some users report instability with 26.5.x and 26.6.1 — system freezes during basic desktop tasks and gaming. If you hit issues, rolling back to 26.3.1 is the first thing to try. See the full breakdown in the companion repo's [KNOWN_ISSUES.md](https://github.com/forkless/ai-ai-ai/blob/main/KNOWN_ISSUES.md).

**Tip:** ComfyUI and its ecosystem move fast — updates roll out constantly, and sometimes an update breaks something that worked yesterday. Running `ai install comfyui` (or `ai install all`) pulls the latest versions and usually sorts it out. When in doubt, update first.

## A Few Things to Know

- **GPU detection**: The scripts check what GPU you have and auto-detect the generation. NVIDIA cards get CUDA (NVIDIA's GPU engine). AMD cards get ROCm on RDNA2+ (RX 6000/7000/9000) or DirectML on RDNA1 (RX 5000). You don't need to pick — the script chooses for you.
- **AMD ROCm vs DirectML**: ROCm is AMD's own GPU compute platform. The script auto-selects it on RDNA2+ hardware (RX 6000, 7000, 9000) with Python 3.12. On RDNA1 (RX 5000), it selects DirectML since ROCm isn't available for that generation. Pass `-Backend directml` to override.

  Here's which cards get which backend:

  | | ROCm (native) | DirectML (fallback) |
  |-|--------------|---------------------|
  | **RDNA4** — RX 9000 series | ✅ auto-selected | ✅ fallback |
  | **RDNA3** — RX 7000 series | ✅ auto-selected | ✅ fallback |
  | **RDNA2** — RX 6000 series | ✅ auto-selected | ✅ fallback |
  | **RDNA1** — RX 5000 series | ❌ not available | ✅ auto-selected |

  ROCm requires driver 26.2.2+ and Python 3.12. DirectML works on any AMD driver and uses Python 3.11.

- **Safe to re-run**: Running a script again won't break anything. It skips what's already there, creates what's missing.
- **Python 3.12**: Installed for the AMD ROCm stack. On AMD RDNA2+ cards, ComfyUI runs on Python 3.12 with ROCm. On RDNA1 or DirectML fallback, it uses Python 3.11. On NVIDIA, it uses Python 3.11 with CUDA.
- **Intel CPU / no GPU**: CPU-only fallback is possible (PyTorch without GPU acceleration) but very slow — practical for testing, not daily use.
- **Root path**: You set your install location once in `1-init.ps1`. The other scripts read it from `system_config.json` — no need to type it again.

## What You're Building

The scripts set up a clean folder structure with 6 sections, each with its own job:

```
AI_CONFIG     → settings, which models you have, port configuration
AI_CORE       → the apps that do the work (ComfyUI, Ollama, Open Web UI)
AI_VAULT      → your models, stored once, shared by everything
AI_WORKSPACE  → your images, prompts, generated files
AI_TOOLS      → helper scripts and launchers
AI_CACHE      → temporary downloads, logs, and ComfyUI temp data
```

The key idea: your models live in one place. Install, reinstall, or remove any AI tool without losing a single model. Want the full logic behind this? See **[Organize Your AI Folders](organize-your-ai-folders.md)**.

## May the -Force Be With You

Each script builds on the one before it. Step 1 creates the folders and config that step 2 reads. Step 2 installs the tools that step 3 and step 4 need. Step 3 installs ComfyUI. Step 4 makes the `ai` command available everywhere. Don't skip ahead — the restarts between steps are intentional.

The diagram below walks through each step — from an empty machine to a running AI stack. The colored arrows show which GPU path applies to your hardware.

<div class="flow-chart" style="position: relative; margin: 16px 0; border: 1px solid #e0e0e0; border-radius: 6px; background: #fafafa;">
  <div class="flow-fs-header" style="display: none; text-align: center; font-size: 1.5em; padding: 20px 0 0 0;"><span style="color: #ccc;">From zero to ai start all</span></div>
  <div class="flow-panzoom" style="display: flex; justify-content: center; align-items: center;">
    <img src="https://raw.githubusercontent.com/forkless/ai-ai-ai/main/flow/bootstrap.svg" alt="Bootstrap process flow" style="max-width: 100%; height: auto; display: block;">
  </div>
  <div style="position: absolute; bottom: 8px; right: 8px; display: flex; gap: 4px;">
    <button class="flow-btn" data-action="zoom-in" title="Zoom in" style="width: 32px; height: 32px; border: 1px solid #ccc; border-radius: 4px; background: #fff; cursor: pointer; font-size: 16px; line-height: 1; display: flex; align-items: center; justify-content: center;">＋</button>
    <button class="flow-btn" data-action="zoom-out" title="Zoom out" style="width: 32px; height: 32px; border: 1px solid #ccc; border-radius: 4px; background: #fff; cursor: pointer; font-size: 16px; line-height: 1; display: flex; align-items: center; justify-content: center;">−</button>
    <button class="flow-btn" data-action="reset" title="Reset" style="width: 32px; height: 32px; border: 1px solid #ccc; border-radius: 4px; background: #fff; cursor: pointer; font-size: 14px; line-height: 1; display: flex; align-items: center; justify-content: center;">⟲</button>
    <button class="flow-btn" data-action="fullscreen" title="Fullscreen" style="width: 32px; height: 32px; border: 1px solid #ccc; border-radius: 4px; background: #fff; cursor: pointer; font-size: 14px; line-height: 1; display: flex; align-items: center; justify-content: center;">⛶</button>
    <button class="flow-btn flow-exit-btn" data-action="exit-fullscreen" title="Exit fullscreen" style="display: none; width: 32px; height: 32px; border: 1px solid #ccc; border-radius: 4px; background: #fff; cursor: pointer; font-size: 14px; line-height: 1; align-items: center; justify-content: center;">✕</button>
  </div>
</div>
<em style="display: block; text-align: left; font-size: 0.9em; color: #666; margin: 3px 2px 8px 2px;">From zero to <code>ai start all</code></em>

**Why restart?** When you install software, Windows adds it to your system PATH so you can run it from anywhere. But currently open windows don't see the change. Close and reopen, and everything works. The restart after step 2 also loads the new environment variables (`OLLAMA_MODELS`, `HF_HOME`, `TORCH_HOME`) — without them, step 3 will fail its environment check.

## The Scripts

| Script | What it does |
|--------|-------------|
| **[1-init.ps1](https://github.com/forkless/ai-ai-ai/blob/main/scripts/1-init.ps1)** | Lays the foundation. Creates the folder structure (6 layers with ~38 directories), detects NVIDIA or AMD GPU, sets up symbolic links from `AI_CORE\_bindings` to `AI_VAULT`, and writes three config files: `system_config.json`, `model_registry.json`, `ports.json`. **Does not install anything.** Needs admin rights or Developer Mode for the symbolic links. |
| **[2-deps.ps1](https://github.com/forkless/ai-ai-ai/blob/main/scripts/2-deps.ps1)** | Installs system software — Git, Python 3.10, Python 3.11, Python 3.12 (for the AMD stack), Ollama, and FFmpeg — all through winget. Then sets three environment variables (`OLLAMA_MODELS`, `HF_HOME`, `TORCH_HOME`) to keep models and caches in their proper folders. **Requires admin rights.** |
| **[3-apps.ps1](https://github.com/forkless/ai-ai-ai/blob/main/scripts/3-apps.ps1)** | Installs ComfyUI (and optionally Open Web UI) into `AI_CORE\Apps`, creates an isolated Python virtual environment (3.12 on AMD RDNA2+, 3.11 otherwise), installs GPU-appropriate PyTorch (CUDA for NVIDIA, ROCm for AMD — AMD's own GPU engine), writes a config file that tells ComfyUI where your vault models live, and generates launcher scripts that read port and settings from `ports.json`. On older AMD cards or unsupported drivers, falls back to DirectML (Microsoft's GPU compute layer) automatically. |
| **[ai.ps1](https://github.com/forkless/ai-ai-ai/blob/main/scripts/ai.ps1)** | Your daily driver — start, stop, restart services; check status with a compact dashboard; run full diagnostics (`ai doctor`, including ROCm check); list installed models; clear cache; install or remove apps; configure ports and environment variables; live-tail service logs. |

## Download the Scripts

**Download the scripts — pick one:**

```powershell
# Option A: Clone the repo (keeps auto-updating with git pull)
git clone https://github.com/forkless/ai-ai-ai.git
cd ai-ai-ai

# Option B: Download the latest release zip, then extract
# Visit https://github.com/forkless/ai-ai-ai/releases
# Download the latest zip, extract somewhere, cd into scripts/
```

After downloading, unblock the scripts if you used the zip:

```powershell
Get-ChildItem *.ps1 | Unblock-File
```

> **⚠️** These scripts are functional but still rough around the edges — incomplete error handling, uncovered edge cases. They work, but proceed with patience.

## Environment Variables (What They Are)

Think of these as shortcuts that tell your tools where to put things. The scripts set them automatically, but here's what they control:

| Shortcut | Points to | What it does |
|----------|-----------|-------------|
| `OLLAMA_MODELS` | `AI_VAULT\models\llm` | Tells Ollama to store models in the vault |
| `HF_HOME` | `AI_CACHE\huggingface` | Keeps Hugging Face downloads in the cache folder |
| `TORCH_HOME` | `AI_CACHE\torch` | Keeps PyTorch downloads in the cache folder |

If something seems off later, run `ai setup env` to check and fix them.

## Port Configuration

Each service has a default port and listen address set during initialization:

| Service | Default Port | Default Listen Address |
|---------|-------------|----------------------|
| Ollama | 11434 | 0.0.0.0 |
| ComfyUI | 8188 | 0.0.0.0 |
| Open Web UI | 3000 | 0.0.0.0 |

Change ports anytime with `ai setup ports`. Settings save to `AI_CONFIG\ports.json` with a `listen` field controlling which network interface each service binds to. Restart the service after changing.

> **Default is `0.0.0.0` for convenience** — accepts `http://localhost`, `http://127.0.0.1`, `http://192.168.0.x`, and any other local network address. This makes it easy to reach services from other devices on your home network. It **does not** mean your services are exposed to the public internet — no port forwarding, no cloud. But if you do open ports on your router, those services become reachable from outside. Review your firewall settings and avoid forwarding AI tool ports to the open web. For remote access, see [WireGuard](../networking/index.md#wireguard-in-case-your-router-supports-it) (or [Tailscale](../networking/index.md#tailscale) if your router doesn't support it). For nice local URLs, see [Reverse Proxy](../networking/index.md#reverse-proxy-for-nice-urls).

## ComfyUI Launch Settings

The launcher script includes optimizations for speed and memory — you don't need to tweak these. Generated images go to `AI_WORKSPACE\output` and temp files to `AI_CACHE\comfyui_temp` automatically.

## Logging and Diagnostics

All three services write their output to log files at `AI_CACHE\logs\<service>.log` on every start. View live logs with `ai watch <service>`. Logs from previous days are automatically zipped to `AI_CACHE\logs\archive\`; archives older than 7 days are cleaned up.

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
| `launch_comfyui.ps1` | `3-apps.ps1` | ComfyUI with correct GPU backend, port, listen address, and launch flags from `ports.json` |
| `launch_ollama.ps1` | `ai start ollama` (auto-generated) | Ollama in background |
| `launch_openwebui.ps1` | `ai start openwebui` (auto-generated) | Open Web UI |

The ComfyUI launcher is generated during setup. The others are created the first time you run `ai start <service>`. All three read the current port and listen address from `ports.json`, so changing ports with `ai setup ports` takes effect on the next launch without re-installing anything.

You can also run any launcher directly from `AI_TOOLS\`.

**Note:** The bootstrap scripts install and configure everything, but don't start the services. You need to launch them manually when you want to use them.

## After Everything Runs

Open a fresh PowerShell window and try:

| Command | What it does |
|---------|-------------|
| `ai start all` | Starts all services (quiet on success; errors dump log tail) |
| `ai stop all` | Stops all services (quiet on success) |
| `ai restart all` | Restarts all services |
| `ai status` | Compact dashboard — running services, ports, model counts |
| `ai status ollama` | Check a single service (ollama, comfyui, or openwebui) |
| `ai doctor` | Full system diagnostics (Git, Python, Ollama, FFmpeg, architecture, ComfyUI, Open Web UI, ROCm, model bindings, env vars) |
| `ai list` | Lists every installed model, grouped by category |
| `ai install all` | Install or update everything at once (stops services first; exits if a service can't be stopped within 10 seconds) |
| `ai install comfyui -Backend directml` | Force DirectML backend on AMD (fallback for older cards or drivers) |
| `ai install comfyui-manager` | Adds custom node browser to ComfyUI |
| `ai install openwebui` | Installs Open Web UI for Ollama |
| `ai remove comfyui` | Remove an installed app (keeps models in vault) |
| `ai setup ports` | Change service ports and listen address |
| `ai setup env` | Check and fix environment variables |
| `ai setup path` | Add `ai` to your PATH so it works from any folder |
| `ai watch comfyui` | Live-tail service logs from `AI_CACHE\logs` (comfyui, ollama, openwebui) |
| `ai clean cache` | Free up space by emptying AI_CACHE and archived logs |
| `ai help` | Show the full command reference |
| `ollama pull llama3` | Downloads a model (lands in the vault via OLLAMA_MODELS) |
