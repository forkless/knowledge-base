← [Setup](../)

# Organize Your AI Folders

## Core Idea

Instead of mixing everything into one folder, the system is split into 5 clear layers:

- **AI_CORE** — running engines (ComfyUI, LM Studio, Ollama)
- **AI_VAULT** — permanent models (LLMs, diffusion, embeddings)
- **AI_WORKSPACE** — input, output, and workflow files
- **AI_TOOLS** — helper scripts and utilities
- **AI_CACHE** — temporary downloads and caches (added as the system evolved)

> This avoids duplication, keeps models stable, and makes tools interchangeable.

## Final Folder Structure

```
D:\AI\
│
├── AI_CORE
│   │
│   ├── ComfyUI
│   │   ├── app
│   │   ├── venv
│   │   ├── venv_py310
│   │   └── custom_nodes
│   │
│   ├── Ollama
│   │
│   ├── LM Studio
│   │
│   ├── environments
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

> This structure separates runtimes (CORE), permanent assets (VAULT), workspace (WORKSPACE), utilities (TOOLS), and temporary data (CACHE).

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
        │  ComfyUI             │
        │  Ollama              │
        │  LM Studio           │
        └──────────┬───────────┘
                   │
          ┌────────┴────────┐
          ▼                 ▼
  ┌──────────────┐  ┌──────────────┐
  │ AI_WORKSPACE │  │  AI_CACHE    │
  │(User Files)  │  │(Temp Data)   │
  └──────────────┘  └──────────────┘
```

## Design Philosophy

Think of it like a real system:

| Layer | Role | Analogy |
|-------|------|---------|
| AI_CORE | Runtimes | Engines in a machine |
| AI_VAULT | Permanent models | Fuel and parts |
| AI_WORKSPACE | User files | Factory output |
| AI_TOOLS | Scripts and utilities | Maintenance tools |
| AI_CACHE | Temporary data | Workbench scraps |

The goal is modularity: any engine can be replaced without touching your data.

## Why This Structure Works

- **Separation of concerns**: engines, data, tools, and temp files are independent
- **No model duplication**: VAULT is single source of truth
- **Safe upgrades**: CORE can be deleted and reinstalled without losing models
- **Scalable**: new AI apps slot into CORE without restructuring everything

## File Access Model (Important)

Models in AI_VAULT are:

- Read-only during inference
- Loaded into RAM or VRAM by AI_CORE apps
- Not modified during normal usage

> File conflicts only happen if multiple tools try to download into the same model directory. Inference itself is safe.

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
- No cache files mixed with models

## Ownership Boundaries

Each layer has a defined access level:

| Layer | Read | Write |
|-------|------|-------|
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

*This is a planned automation script — not yet implemented.*

The bootstrap should:

1. Create the full directory structure
2. Install prerequisites (Git, Python 3.10, Python 3.11, Ollama)
3. Configure environment variables (OLLAMA_MODELS, HF_HOME, TORCH_HOME)
4. Create the `_bindings` directory
5. Verify the installation
6. Prepare runtime directories and venvs

When complete, the system provides:

- Modular architecture
- Centralized model storage
- Zero model duplication
- Safe engine replacement
- Isolated cache management
- Reproducible deployment
- Long-term maintainability
