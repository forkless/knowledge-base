← [Home](..)

# FAQ

## "Command not found" after installing

Tools like Git, Python, and Ollama are installed but PowerShell can't find them.

**Fix:** Close all PowerShell windows and open a new one. Windows updates PATH when software is installed, but already open windows don't reload it.

If you still see the error, verify the tool is actually installed:

```powershell
where git
where python
where ollama
```

If `where` doesn't find it, run the install script again.

## Scripts won't run ("not digitally signed")

PowerShell blocks scripts downloaded from the internet.

**Fix:**

```powershell
Unblock-File *.ps1
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Only needed once after downloading.

## Venv activation blocked

PowerShell's execution policy prevents running the activation script.

**Fix:**

```powershell
Set-ExecutionPolicy -Scope CurrentUser RemoteSigned
```

Or use the full path to Python:

```powershell
.\venv\Scripts\python.exe main.py
```

## ComfyUI shows "Torch not compiled with CUDA enabled"

The CUDA version of PyTorch was installed but your AMD GPU can't use it.

**Fix:** Re-run the install:

```powershell
ai install comfyui
```

The script detects the AMD GPU, recreates the venv, and installs torch-directml.

## Symbolic links fail

`mklink` requires Administrator rights or Developer Mode.

**Fix:** Run PowerShell as Administrator, or enable Developer Mode:

- Windows 11: **Settings → Privacy & Security → For Developers → Developer Mode**
- Windows 10: **Settings → Update & Security → For Developers → Developer Mode**

## Open Web UI won't start (port in use)

Shows `[Errno 10048] error while attempting to bind on address`.

**Fix:** Change the port:

```powershell
ai setup ports
```

Set Open Web UI to a different port, then restart.

## Pip version notice

```
[notice] A new release of pip is available: 24.0 -> 26.1.2
```

A notification, not an error. The pip version that comes with Python 3.11 works perfectly. Ignore it.

## "Skipped (already up to date)" in install summary

```
Install Summary
  Git: Skipped (already up to date)
```

Normal - means the tool was already installed with no newer version available.

## FFmpeg shows "not found" in doctor

Ran `2-deps.ps1` but doctor still reports FFmpeg missing.

**Fix:** Restart PowerShell. The current window doesn't see the PATH update.

## Models are gone after setting OLLAMA_MODELS

The variable was set after pulling models, so they're still in the old location.

**Fix:** Set `OLLAMA_MODELS` before pulling. Old models at `C:\Users\<you>\.ollama\models\blobs` can be deleted to free space.

## AMD driver instability (Adrenalin 26.5.x / 26.6.1)

Some RX 7000 and 9000 series users report system-wide freezes with newer AMD drivers - even during basic desktop tasks, not just AI workloads. The RX 7000 series is the primary AMD platform for this stack, and **Adrenalin 26.3.1** is the recommended stable version for AI, gaming, and daily use.

**Fix:** Roll back to 26.3.1 if you hit freezes or crashes, especially in games or GPU-heavy apps.

See the full breakdown in [KNOWN_ISSUES.md](https://github.com/forkless/ai-ai-ai/blob/main/KNOWN_ISSUES.md).

## Venv keeps getting recreated

The script detected an AMD GPU with CUDA torch installed and recreates the venv. Intentional - prevents the "Torch not compiled with CUDA" crash.

## Can I move the AI root after setup?

Update the path in `AI_CONFIG\system_config.json`, re-run `ai setup env`, then re-run `ai install comfyui` to regenerate launcher scripts with the new paths.
