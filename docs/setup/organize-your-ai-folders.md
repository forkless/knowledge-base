← [Setup](../)

# Organize Your AI Folders

## Core Idea

Instead of mixing everything into one folder, the system is split into 6 clear layers:

- **AI_CONFIG** — centralized configuration and model registry
- **AI_CORE** — the apps and engines that do the work (ComfyUI, Ollama, Open Web UI)
- **AI_VAULT** — permanent models (LLMs, diffusion, embeddings)
- **AI_WORKSPACE** — input, output, and workflow files
- **AI_TOOLS** — helper scripts and utilities
- **AI_CACHE** — temporary downloads and caches

> This avoids duplication, keeps models stable, and makes tools interchangeable. Architecture evolves but the principles stay the same.

## Final Folder Structure

```
<AI_ROOT>\               (e.g. D:\AI\)
│
├── AI_CONFIG
│   ├── system_config.json
│   ├── model_registry.json
│   └── ports.json
│
├── AI_CORE
│   │
│   ├── Apps
│   │   ├── ComfyUI
│   │   └── Open Web UI
│   │
│   ├── Services
│   │   └── Ollama
│   │
│   ├── Environments
│   │
│   └── _bindings
│       ├── llm        → AI_VAULT\models\llm
│       ├── diffusion  → AI_VAULT\models\diffusion
│       └── embeddings → AI_VAULT\models\embeddings
│
├── AI_VAULT
│   │
│   ├── models
│   │   ├── llm
│   │   ├── diffusion
│   │   │   ├── checkpoints
│   │   │   ├── diffusion_models
│   │   │   ├── loras
│   │   │   ├── vae
│   │   │   ├── controlnet
│   │   │   ├── unet
│   │   │   ├── text_encoders
│   │   │   ├── upscale_models
│   │   │   ├── ipadapter
│   │   │   ├── style_models
│   │   │   ├── clip_vision
│   │   │   ├── clip
│   │   └── embeddings
│   │
│   └── datasets
│
├── AI_WORKSPACE
│   │
│   ├── workflows
│   ├── input
│   ├── output
│   └── sessions
│
├── AI_TOOLS
│   │
│   ├── scripts
│   ├── converters
│   └── utilities
│
└── AI_CACHE
    │
    ├── huggingface
    ├── torch
    ├── comfyui_temp
    └── logs
```

> This structure separates configuration, runtimes, assets, workspace, tools, and caches into independent layers.

## How the Layers Connect

```
        ┌──────────────────────┐
        │      AI_TOOLS        │
        │  (Manages Models)    │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │      AI_VAULT        │
        │  (Permanent Assets)  │
        └──────────┬───────────┘
                   │
                   ▼
        ┌──────────────────────┐
        │  AI_CORE / _bindings │
        │   (Model Routing)    │
        ├──────────────────────┤
        │  Apps, Services      │
        │  Environments        │
        └──────────┬───────────┘
                   │
          ┌────────┴────────┐
          ▼                 ▼
  ┌──────────────┐  ┌──────────────┐
  │ AI_WORKSPACE │  │  AI_CACHE    │
  │(User Files)  │  │(Temp Data)   │
  └──────────────┘  └──────────────┘

        ┌──────────────────────┐
        │     AI_CONFIG        │
        │  (System Config)     │
        └──────────────────────┘
```

## Design Philosophy

Think of the environment as a complete operating platform for AI workloads:

| Layer | Role | Analogy |
|-------|------|---------|
| AI_CONFIG | Configuration | Control panel |
| AI_CORE | Runtimes | Engines in a machine |
| AI_VAULT | Permanent models | Fuel and parts |
| AI_WORKSPACE | User files | Factory output |
| AI_TOOLS | Scripts and utilities | Maintenance tools |
| AI_CACHE | Temporary data | Workbench scraps |

The architecture separates execution from storage. Applications consume resources from centralized locations rather than maintaining private copies. The goal is modularity: any engine can be replaced without touching your data.

## Why This Structure Works

- **Separation of concerns**: config, engines, data, tools, and temp files are independent
- **No model duplication**: VAULT is single source of truth
- **Safe upgrades**: CORE can be deleted and reinstalled without losing models
- **Scalable**: new AI apps slot into CORE without restructuring everything

## Layer Details

### AI_CONFIG

Centralized configuration layer. No models, no executables, no cache — just metadata.

```
AI_CONFIG
├── system_config.json       ← architecture version, root path, GPU type
├── model_registry.json      ← installed models with paths and formats
└── ports.json               ← service ports and listen address
```

**system_config.json:**

```json
{
  "architecture_version": "0.1.1",
  "platform": "windows",
  "root": "D:\\AI",
  "vault": "D:\\AI\\AI_VAULT",
  "workspace": "D:\\AI\\AI_WORKSPACE",
  "cache": "D:\\AI\\AI_CACHE",
  "gpu": "amd"
}
```

**model_registry.json:**

```json
{
  "models": [
    {
      "name": "Llama-3",
      "type": "llm",
      "format": "gguf",
      "path": "AI_VAULT/models/llm/llama3"
    }
  ]
}
```

### AI_CORE

Contains all the AI software. Split into Apps (programs you interact with), Services (background processes), and Environments (isolated Python setups for each app).

- **Apps**: ComfyUI, Open Web UI
- **Services**: Ollama
- **Environments**: isolated Python venvs per runtime
- **_bindings**: symbolic links to AI_VAULT

AI_CORE is disposable — reinstall without affecting any other layer.

### AI_VAULT

Single source of truth for all models and datasets. Models are stored once and consumed by every runtime through the binding layer.

- **models/llm** — GGUF, GPTQ, exl2 formats
- **models/diffusion** — checkpoints, diffusion_models, LoRAs, VAEs, ControlNet, UNet, text encoders, upscale models, IPAdapter, style models, CLIP vision, CLIP
- **models/embeddings** — text embeddings, clip models
- **datasets** — training data, reference sets

Never sync AI_VAULT with OneDrive or cloud folders. Back it up separately.

### AI_WORKSPACE

User-facing work area. Input files, generated outputs, workflow definitions, and session data.

Safe to archive independently. Safe to clean without affecting installed runtimes.

### AI_TOOLS

Automation and maintenance layer. Scripts for environment validation, model management, backups, and conversion.

Only AI_TOOLS should intentionally modify AI_VAULT.

### AI_CACHE

Temporary data that is safe to delete and rebuild. Contains Hugging Face cache, PyTorch cache, ComfyUI temp files, and service logs (`AI_CACHE\logs\<service>.log`). Logs older than 7 days are automatically cleaned up during log rotation.

## Model Routing with Symbolic Links

AI applications often create their own model folders, causing duplication and wasted space. The solution is a binding layer at `AI_CORE\_bindings` using symbolic links — think of it as a hallway: the apps think they're finding models locally, but the hallway leads to your vault.

**The flow:**

```
AI engine looks for models
        ↓
AI_CORE\_bindings (symbolic links)
        ↓
AI_VAULT\models (actual files)
```

**Setup (run once):**

```powershell
mklink /D D:\AI\AI_CORE\_bindings\llm D:\AI\AI_VAULT\models\llm
mklink /D D:\AI\AI_CORE\_bindings\diffusion D:\AI\AI_VAULT\models\diffusion
mklink /D D:\AI\AI_CORE\_bindings\embeddings D:\AI\AI_VAULT\models\embeddings
```

The engine believes it's reading from a local model directory, but the actual files stay centralized.

**ComfyUI model paths:**

```
AI_CORE\_bindings\diffusion\checkpoints
AI_CORE\_bindings\diffusion\loras
AI_CORE\_bindings\diffusion\vae
AI_CORE\_bindings\diffusion\controlnet
AI_CORE\_bindings\diffusion\unet
AI_CORE\_bindings\diffusion\text_encoders
AI_CORE\_bindings\diffusion\upscale_models
AI_CORE\_bindings\diffusion\ipadapter
AI_CORE\_bindings\diffusion\style_models
AI_CORE\_bindings\diffusion\clip_vision
AI_CORE\_bindings\diffusion\clip
AI_CORE\_bindings\diffusion\diffusion_models
AI_CORE\_bindings\embeddings
```

**Ollama model path (set via environment variable):**

The script sets `OLLAMA_MODELS` to point directly to the vault — not to the bindings layer. This keeps Ollama's own model management clean while runtimes like ComfyUI continue to use the symlink binding layer.

```powershell
setx OLLAMA_MODELS "D:\AI\AI_VAULT\models\llm"
```

## Cache Isolation

Download caches must never enter AI_VAULT. Set these environment variables:

```powershell
setx HF_HOME "D:\AI\AI_CACHE\huggingface"
setx TORCH_HOME "D:\AI\AI_CACHE\torch"
```

Benefits:

- Easy cleanup — delete the entire cache folder
- Predictable storage usage
- Prevents pollution of permanent assets

## Ownership Boundaries

Each layer has a defined access level:

| Layer | Read | Write |
|-------|------|-------|
| AI_CONFIG | Yes | Yes |
| AI_CORE | Yes | Runtime only |
| AI_VAULT | Yes | AI_TOOLS only |
| AI_WORKSPACE | Yes | Yes |
| AI_TOOLS | Yes | Yes |
| AI_CACHE | Yes | Yes |

Only AI_TOOLS may intentionally modify AI_VAULT. Runtimes should consume models, not manage them.

## Rules for Stability

- Only AI_TOOLS should manage downloads into AI_VAULT (or disable auto-downloads per tool)
- Keep outputs separate from models
- Do not mix caches with VAULT
- Avoid syncing AI_VAULT with OneDrive or cloud folders
- AI_CACHE is safe to delete entirely at any time
- AI_CORE is disposable — reinstall without affecting data

## GPU Support Notes

The folder structure itself works with any GPU — it's just a way to organize files. The bootstrap scripts handle the rest:

- **NVIDIA** — CUDA, any CUDA-capable card
- **RDNA1** (RX 5000) — DirectML only
- **RDNA2** (RX 6000) — DirectML only
- **RDNA3** (RX 7000) — ROCm native, DirectML fallback
- **RDNA4** (RX 9000) — ROCm native, DirectML fallback

Older GCN-based cards lack DirectML optimization and are not recommended for AI workloads.

**Intel & CPU fallback:** Intel Arc GPUs may work through DirectML but are not tested. Running on CPU alone is possible (via DirectML's software fallback) but will be very slow — not useful for daily driving.

## Prerequisites

Before setting up this structure, see the **[Windows Setup Guide](windows-setup.md)** for installing Git, Python, and Ollama.

## Bootstrap Scripts

Three numbered scripts automate the deployment. See the **[Bootstrap Scripts Guide](bootstrap-scripts.md)** for full details, prerequisites, and deployment order.

- **1-init.ps1** — folders, bindings, config files
- **2-deps.ps1** — Git, Python 3.10/3.11/3.12, Ollama, FFmpeg
- **3-comfyui.ps1** — clone, venv, model paths, launcher

## Roadmap

| Phase | What | Status |
|-------|------|--------|
| 1 | Architecture definition | Complete |
| 2 | Bootstrap installer | Complete |
| 3 | ComfyUI deployment script (clone, venv, extra model paths, launchers) | Complete |
| 4 | Model management (register, verify hashes, track versions) | Planned |
| 5 | Application expansion (Open Web UI) | Complete |

No architectural changes required for future phases — new apps slot into AI_CORE without restructuring.
