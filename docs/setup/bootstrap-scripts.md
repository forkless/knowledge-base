# Ai, ai, ai! Bootstrap v1.1

Three scripts automate the whole setup — folders, software, and ComfyUI. A fourth script (`ai`) handles daily tasks like starting services and checking what's running.

You can find them in the `scripts/` folder of this repo, or grab the [latest release zip](https://github.com/forkless/knowledge-base/releases/tag/v1.1).

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
| **[1-init.ps1](https://github.com/forkless/knowledge-base/blob/master/scripts/1-init.ps1)** | Creates all the folders, links, and config files. Detects your GPU type. Does not install anything. |
| **[2-deps.ps1](https://github.com/forkless/knowledge-base/blob/master/scripts/2-deps.ps1)** | Installs Git, Python, Ollama, and FFmpeg. Sets up environment variables so models go to the right place. |
| **[3-comfyui.ps1](https://github.com/forkless/knowledge-base/blob/master/scripts/3-comfyui.ps1)** | Downloads ComfyUI, creates a Python environment, sets up model paths, and creates a launcher. |
| **[ai.ps1](https://github.com/forkless/knowledge-base/blob/master/scripts/ai.ps1)** | Your daily driver — start, stop, restart services; check status and ports; list models; clean cache; fix settings and install/remove apps. |

## Run Order

Scripts must run in this order. Each one prepares something the next one needs.

```
1. 1-init.ps1         create folders + links + config
       ↓
   Restart PowerShell — lets it find newly installed tools
       ↓
2. 2-deps.ps1         install Git, Python, Ollama, FFmpeg
       ↓
   Restart PowerShell — lets it find newly installed tools
       ↓
3. 3-comfyui.ps1      install ComfyUI, set up model paths
```

**Why restart?** When you install software, Windows adds it to your system PATH so you can run it from anywhere. But currently open windows don't see the change. Close and reopen, and everything works.

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

Each service has a default port set during initialization:

| Service | Default Port |
|---------|-------------|
| Ollama | 11434 |
| ComfyUI | 8188 |
| Open Web UI | 8080 |

Change them anytime with `ai setup ports`. Settings save to `AI_CONFIG\ports.json`. Restart the service after changing.

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

| Script | Starts |
|--------|--------|
| `launch_ollama.ps1` | Ollama in background |
| `launch_comfyui.ps1` | ComfyUI with correct GPU backend |
| `launch_openwebui.ps1` | Open Web UI |

These are auto-generated when you run `ai start <service>` for the first time. You can also run them directly from `AI_TOOLS\`.

**Note:** The scripts install and configure everything, but don't start the services. You need to launch them manually when you want to use them.

## After Everything Runs

Open a fresh PowerShell window and try:

| Command | What it does |
|---------|-------------|
| `ai start all` | Starts all services |
| `ai stop all` | Stops all services |
| `ai restart all` | Restarts all services |
| `ai doctor` | Full system diagnostics (Git, Python, services, env) |
| `ai status` | Compact dashboard — running services, ports, model counts |
| `ai models list` | Lists every model, grouped by category |
| `ai install comfyui-manager` | Adds custom node browser to ComfyUI |
| `ai install openwebui` | Installs Open Web UI for Ollama |
| `ai setup ports` | Change service ports |
| `ai clean cache` | Free up space |
| `ollama pull llama3` | Downloads a model (lands in the vault) |
