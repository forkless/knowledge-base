---
name: documents
description: Documentation agent pattern — project onboarding, changelog tracking, workspace layout.
---

# Documentation Agent Pattern

When working with a new project that needs documentation:

## 1. Look for PROJECT.md

Read it first. It should contain the project's purpose, structure, key files, external dependencies, release cadence, and any doc site publishing pipeline. If it doesn't exist, the project isn't set up for documentation yet — create one from the codebase analysis.

## 2. Check for CHANGES.md

If it exists, read it to learn what's changed since the last doc update. If it doesn't exist, work from git log or direct file comparison.

## 3. Verify workspace layout

If the project has a sibling repository with the actual source code (e.g. `ai-ai-ai` next to `knowledge-base`), confirm it's reachable under the workspace. Structured tools (`read_file`, `grep_files`) work best when source is accessible.

## 4. Document from source, not memory

Always read the actual files before documenting. Never describe behavior based on prior sessions or memory — code drifts, and the evidence is in the source.

### DECISIONS.md — design rationale

If a `DECISIONS.md` exists at the project root, read it before making any documentation claims about why something works the way it does. It contains the rationale that the code cannot express.

Each entry follows this format:

```markdown
## Why <decision>

Context: what prompted the decision. Alternatives: what was considered and rejected. Outcome: what was chosen and why.
```

If `DECISIONS.md` doesn't exist and you encounter a non-obvious design choice during documentation, flag it in a comment rather than inferring intent. Example:

```
<!-- TODO: document why extra_model_paths.yaml needs a named config block -->
```

## 5. Cross-reference conventions

- Docs stay in `docs/` as markdown
- Each doc has a back-link to its parent section
- No horizontal rules in markdown (`---`)
- Code blocks have language tags
- Blockquotes use `> ` for notes, `> - ` for lists inside blockquotes

## Templates

### PROJECT.md — place at project root

```markdown
# Project: <name>

## Purpose
<one paragraph>

## Structure
- src/          — main source code
- tests/        — test suite
- scripts/      — build and deployment scripts

## Key files
- main.py       — entry point
- config.toml   — runtime configuration

## External dependencies
- Python 3.11
- PostgreSQL 16

## Release cadence
- Tags: v0.x.y
- CI builds on tag, publishes to GitHub Releases

## Docs site
- Published via GitHub Pages from docs/ folder
```

### CHANGES.md — one entry per release, appended when changes land

```markdown
# Changes

## v1.2 (2026-06-03)

- ComfyUI launcher: added --listen 0.0.0.0 flag
- ai doctor: replaced linear output with box-drawing table
- Ollama launcher: sets OLLAMA_HOST automatically on start

## v1.1 (2026-06-01)

- Initial GPU detection support
- AMD DirectML backend
- Environment variable guards in 2-deps.ps1
```
