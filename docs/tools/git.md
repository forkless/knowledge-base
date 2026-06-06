← [Tools](../)

# Git

Git is the version control system used to clone and update most AI tools. You don't need to be a Git expert - just a few commands cover most of what you'll do.

## Cloning a Repository

The most common Git operation in an AI setup:

```powershell
git clone https://github.com/owner/repo.git
```

This downloads the repo into a folder named after it. To update later:

```powershell
git pull
```

## Basic Workflow

```powershell
# Check what's changed
git status

# Stage files for commit
git add .

# Commit with a message
git commit -m "Describe what you changed"

# Push to remote
git push
```

## Branching

```powershell
# Create and switch to a new branch
git checkout -b my-feature

# Switch back to main
git checkout main

# Merge a branch into main
git merge my-feature
```

## .gitignore

A `.gitignore` file tells Git which files to ignore - venvs, caches, API keys, OS junk.

```gitignore
# Python virtual environments
venv/
.env/

# OS files
.DS_Store
Thumbs.db

# AI model files (too large for Git)
*.pt
*.pth
*.bin
*.safetensors
```

## Useful for AI Work

```powershell
# Shallow clone - faster, no full history
git clone --depth 1 https://github.com/owner/repo.git

# Check tags (for stable versions)
git tag

# Checkout a specific tag
git checkout v1.2.3
```

## When to Re-Clone

If a repo gets into a broken state after a failed update:

```powershell
# Save any local changes first
# Then delete and re-clone
cd ..
rmdir repo /s
git clone https://github.com/owner/repo.git
```

It's faster than untangling merge conflicts.
