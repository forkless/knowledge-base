← [Backup](..)

# Backup

AI models are large - often 2–15 GB each - and re-downloading them is slow. A solid backup plan saves hours.

## What to Back Up

- **Model files** (`.safetensors`, `.bin`, `.pt`) - irreplaceable or time-consuming to re-download
- **Config files** - workflow settings, custom node configs, environment variables
- **Outputs** - generated images, prompts, results (if you want to keep them)

## What Not to Back Up

- **Virtual environments** (`venv/`) - recreate with `pip install -r requirements.txt`
- **Git repos** - re-clone instead
- **Cache folders** - HuggingFace cache, pip cache, etc.

## Storage Tips

**Keep models on a separate drive:**

```
D:\AI_VAULT\models\
├── llm\              ← 10–50 GB each
├── diffusion\        ← 2–7 GB each
└── embeddings\       ← smaller
```

**Avoid syncing AI_VAULT with OneDrive, Dropbox, or Google Drive** - they'll choke on multi-GB model files and may corrupt them.

## Backup Strategy

**For models:**
- Copy to an external drive as-is (they're just files)
- Note down model URLs or HuggingFace IDs in a text file so you know what you had

**For configs:**
- Keep them in a Git repo (small text files)
- Document custom node URLs in a list

**Quick backup script (PowerShell):**

```powershell
robocopy D:\AI_VAULT F:\backup\AI_VAULT /MIR /R:2 /W:5
```

`/MIR` mirrors the folder structure. `/R:2 /W:5` retries twice with a 5-second wait.
