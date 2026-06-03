← [Setup](../)

# Organize Your AI Folders

## Core Idea

Instead of mixing everything into one folder, the system is split into 6 clear layers:

- **AI_CONFIG** — centralized configuration and model registry
- **AI_CORE** — AI runtimes and applications (ComfyUI, Ollama, LM Studio)
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
│   └── app_configs
│       ├── comfyui
│       └── ollama
│
├── AI_CORE
│   │
│   ├── Apps
│   │   ├── ComfyUI
│   │   └── LM Studio
│   │
│   ├── Services
│   │   └── Ollama
│   │
│   ├── Environments
│   │   ├── python311_base
│   │   └── python310_legacy
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
│   │   │   ├── loras
│   │   │   ├── vae
│   │   │   └── controlnet
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
    └── ollama
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
└── app_configs
    ├── comfyui
    └── ollama
```

**system_config.json:**

```json
{
  "architecture_version": "1.1",
  "platform": "windows",
  "root": "D:\\AI",
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

Contains all AI runtimes. Split into Apps (user-facing), Services (background daemons), and Environments (Python venvs).

- **Apps**: ComfyUI, LM Studio
- **Services**: Ollama
- **Environments**: isolated Python venvs per runtime
- **_bindings**: symbolic links to AI_VAULT

AI_CORE is disposable — reinstall without affecting any other layer.

### AI_VAULT

Single source of truth for all models and datasets. Models are stored once and consumed by every runtime through the binding layer.

- **models/llm** — GGUF, GPTQ, exl2 formats
- **models/diffusion** — checkpoints, LoRAs, VAEs, ControlNet
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

Temporary data that is safe to delete and rebuild. Contains Hugging Face cache, PyTorch cache, ComfyUI temp files, and Ollama temp data.

## Model Routing with Symbolic Links

AI applications often create their own model folders, causing duplication and wasted space. The solution is a binding layer at `AI_CORE\_bindings` using symbolic links.

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
```

**Ollama model path (set via environment variable):**

```powershell
setx OLLAMA_MODELS "D:\AI\AI_CORE\_bindings\llm"
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

## Prerequisites

Before setting up this structure, see the **[Windows Setup Guide](windows-setup.md)** for installing Git, Python, and Ollama.

## Bootstrap Installer

The bootstrap installer is **complete** and performs:

1. Select installation location
2. Create the full directory structure
3. Install Git, Python 3.10, Python 3.11, and Ollama
4. Configure environment variables (OLLAMA_MODELS, HF_HOME, TORCH_HOME)
5. Create the `_bindings` directory
6. Generate configuration files (system_config.json, model_registry.json)
7. Verify the installation
8. Prepare runtime directories and venvs

## Roadmap

| Phase | What | Status |
|-------|------|--------|
| 1 | Architecture definition | Complete |
| 2 | Bootstrap installer | Complete |
| 3 | ComfyUI deployment script (clone, venv, extra model paths, launchers) | Next |
| 4 | Model management (register, verify hashes, track versions) | Planned |
| 5 | Application expansion (LM Studio, Open WebUI) | Planned |

No architectural changes required for future phases — new apps slot into AI_CORE without restructuring.
