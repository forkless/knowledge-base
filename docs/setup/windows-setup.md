← [Setup](../)

# AI Stack Prerequisites (Windows Setup Guide)

## Overview

This guide sets up the foundation for a local AI system:

- ComfyUI (image generation engine)
- Ollama (LLM runtime)
- Python (AI tooling runtime)
- Git (source-based installs)

> Goal: create a stable base before installing any AI applications.

## Git (required for ComfyUI + extensions)

```powershell
winget install Git.Git
```

> Git is required to clone ComfyUI and custom nodes. After install, open a **new** PowerShell window.

## Python Versions (AI runtime layer)

Install multiple Python versions side-by-side:

- **3.10** — maximum compatibility fallback for legacy AI tools and custom nodes
- **3.11** — recommended default for modern AI workflows and best overall stability/performance balance

> **Why two Python versions?**
>
> AI tooling evolves unevenly across the ecosystem. Some tools and custom nodes prioritize long-term stability and work best on Python 3.10, while newer libraries and actively maintained projects target Python 3.11. Using both allows separation of stable legacy environments from modern toolchains, reducing dependency conflicts and improving overall reliability.

```powershell
winget install Python.Python.3.10;
winget install Python.Python.3.11
```

> Use the Python launcher instead of system Python: `py -3.11`

> Winget sources can lag behind the latest releases by a few days. If you need a newer version than winget provides, download the installer directly from python.org.

## Verify Python

```powershell
py -0
```

Expected output: `3.11`, `3.10`

## Ollama (no Python required)

```powershell
winget install Ollama.Ollama
```

Ollama runs as a local service: `http://localhost:11434`

> If winget's Ollama version is behind, download the latest installer directly from [ollama.com/download/windows](https://ollama.com/download/windows).

## Critical Windows PATH behavior (IMPORTANT)

After installing tools like Python, Git, or Ollama:

- Windows updates PATH immediately
- BUT existing terminals do **not** reload it

> - You do **not** need to reboot or log out in most cases.
> - You MUST however close PowerShell and open a new one after installs.

## REQUIRED STEP: Refresh your terminal

After every winget install session:

1. Close ALL PowerShell windows
2. Open a new PowerShell window
3. Verify installation

> Why this is needed: PowerShell reads environment variables (PATH) only at startup.

Verify tools:

```powershell
python --version
py -0
git --version
ollama --version
```

## Full system health check (recommended)

Run this anytime to confirm your AI environment is correctly set up.

```powershell
py -0
python --version
git --version
ollama --version
```

> If any command fails after install: reopen PowerShell first, then recheck.

## ComfyUI dependency note

ComfyUI requires:

- Python 3.11 (recommended)
- Python 3.10 (fallback for compatibility edge cases)
- Git
- PyTorch (CUDA or ROCm)

> Use isolated virtual environments per tool. Do not mix dependencies across projects or Python versions.

Later installation will use:

```powershell
py -3.11 -m venv venv
```

## System layout reminder

```
D:\AI\
│
├── AI_CORE        → runtimes (ComfyUI, etc.)
├── AI_VAULT       → models (LLM + diffusion)
├── AI_WORKSPACE   → workflows / input / output
├── AI_TOOLS       → scripts / utilities
```
