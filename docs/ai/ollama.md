← [AI](../)

# Ollama

Ollama runs large language models locally. It handles GPU detection, model downloading, and serving through a simple API.

## Installation

```powershell
winget install Ollama.Ollama
```

Or download the latest installer from [ollama.com/download/windows](https://ollama.com/download/windows).

After install, restart PowerShell and verify:

```powershell
ollama --version
```

Ollama runs as a background service at `http://localhost:11434`.

## Pulling a Model

```powershell
# Small, fast model (good for testing)
ollama pull llama3.2:1b

# Mid-range
ollama pull llama3.1:8b

# Large (needs 16GB+ VRAM or will use system RAM)
ollama pull llama3:70b
```

## Running a Model

```powershell
# Interactive chat
ollama run llama3.1:8b

# API call
curl http://localhost:11434/api/generate -d "{\"model\": \"llama3.1:8b\", \"prompt\": \"Hello\"}"
```

## VRAM Overflow Handling

A major advantage over many other LLM runtimes is Ollama's ability to load models **larger than your VRAM**.

When a model doesn't fit entirely in VRAM:

- As many layers as possible are loaded into GPU memory
- Remaining layers overflow into system RAM
- Inference is slower (CPU fallback for overflowed layers)
- **The model runs at all** — other runtimes would refuse or crash

**Example:** a 20GB model on a 16GB AMD card.

16GB of layers run at full GPU speed. ~4GB of layers fall back to system RAM. The model works. Response times are a bit slower for the overflowed layers, but usable.

This makes Ollama the best option for pushing above your VRAM budget — especially on mid-range AMD cards where VRAM is often the bottleneck.

## Model Storage — Set Before Pulling

Ollama stores models wherever `OLLAMA_MODELS` points. **This must be set before you pull any models.** If you change it after pulling, existing models stay in the old location and the new path sees nothing.

Redirect to the vault:

```powershell
setx OLLAMA_MODELS "D:\AI\AI_VAULT\models\llm"
```

Then:
1. **Close and reopen PowerShell** — `setx` updates the registry, not the current window
2. **Restart the Ollama service** — or restart your computer
3. **Verify** — `echo $env:OLLAMA_MODELS` should show `D:\AI\AI_VAULT\models\llm`
4. **Now pull models** — `ollama pull llama3`

Models pulled before setting this are in `C:\Users\<you>\.ollama\models\blobs` and won't be found by the new path.

## Configuration

Model offloading can be tuned with the `OLLAMA_NUM_PARALLEL` and `OLLAMA_MAX_LOADED_MODELS` environment variables. Defaults work well for most setups.
