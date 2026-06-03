# Organize Your AI Folders

## Core Idea

Instead of mixing everything into one folder, the system is split into 4 clear layers:

- **AI_CORE** — running engines (ComfyUI, LM Studio, Ollama)
- **AI_VAULT** — permanent models (LLMs, diffusion, embeddings)
- **AI_WORKSPACE** — input, output, and workflow files
- **AI_TOOLS** — helper scripts & utilities

> This avoids duplication, keeps models stable, and makes tools interchangeable.

## Final Folder Structure

```
D:\AI\
│
├── AI_CORE
│   │
│   ├── ComfyUI
│   │   ├── venv
│   │   ├── custom_nodes
│   │   └── ComfyUI (git repo)
│   │
│   ├── LM Studio
│   └── Ollama
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
│   └── output
│
└── AI_TOOLS
    │
    ├── scripts
    ├── converters
    └── utilities
```

> This structure separates runtimes (CORE), permanent assets (VAULT), workspace (WORKSPACE), and utilities (TOOLS).

## How It Works (Conceptually)

```
┌──────────────────────────┐
│        AI_CORE           │
│    (Runs Models)         │
├──────────────────────────┤
│  ComfyUI                 │
│  LM Studio               │
│  Ollama                  │
└───────────┬──────────────┘
            │
            v
┌──────────────────────────┐
│       AI_VAULT           │
│   (Permanent Data)       │
├──────────────────────────┤
│  LLM models              │
│  Diffusion models        │
│  Embeddings              │
└───────────┬──────────────┘
            │
            v
┌──────────────────────────┐
│     AI_WORKSPACE          │
│  (Inputs / Outputs)      │
└──────────────────────────┘

┌──────────────────────────┐
│       AI_TOOLS           │
│  (Converters etc.)       │
└──────────────────────────┘
```

## Why This Structure Works

- **Separation of concerns**: engines, data, and tools are independent
- **No model duplication**: VAULT is single source of truth
- **Safe upgrades**: CORE can be deleted/reinstalled without losing models
- **Scalable**: new AI apps slot into CORE without restructuring everything

## File Access Model (Important)

Models in AI_VAULT are:

- Read-only during inference
- Loaded into RAM/VRAM by AI_CORE apps
- Not modified during normal usage

> File conflicts only happen if multiple tools try to download/write into the same model directory. Inference itself is safe.

## Rules for Stability

- Only one system should manage downloads into AI_VAULT (or disable auto-downloads)
- Keep outputs separate from models
- Do not mix caches with VAULT
- Avoid syncing AI_VAULT with OneDrive or cloud folders

## Design Philosophy

Think of it like a real system:

- **AI_CORE** = engines (like engines in a machine)
- **AI_VAULT** = fuel & parts (models)
- **AI_WORKSPACE** = factory output (images, prompts, results)
- **AI_TOOLS** = maintenance tools

> The goal is modularity: any engine can be replaced without touching your data.
