← [Setup](../)

# Windows Setup Guide

These prerequisites are installed automatically by the **[Bootstrap Scripts](bootstrap-scripts.md)**. This page is a quick reference in case you need to install manually or troubleshoot.

## What Gets Installed

| Tool | Purpose |
|------|---------|
| Git | Cloning ComfyUI and custom nodes |
| Python 3.11 | Primary AI runtime |
| Python 3.10 | Legacy compatibility fallback |
| Ollama | Local LLM server |

## Quick Install

```powershell
winget install Git.Git
winget install Python.Python.3.10
winget install Python.Python.3.11
winget install Ollama.Ollama
```

See the **[Bootstrap Scripts Guide](bootstrap-scripts.md)** for the automated version that handles GPU detection, model path config, and the `ai` control panel.

## PATH Behavior (Important)

Windows updates PATH when software is installed. Existing PowerShell windows do **not** reload it.

- You do **not** need to reboot or log out
- You **must** close and reopen PowerShell after each install session
- Skipping this step is the most common cause of "command not found" errors

## Verification

```powershell
py -0
git --version
ollama --version
```

Expected Python versions: `3.11` and `3.10` should both appear.

## Common Pitfalls

- **Winget outdated?** Download installers directly from python.org or ollama.com
- **Command not found?** Close PowerShell and open a fresh window
- **Path with spaces?** Use quotes or the short path (e.g. `D:\AI` not `D:\My AI Stuff`)
