---
name: github
description: "GitHub conventions — repo setup, releases, Pages, CI/CD. Differentiates personal vs professional."
---

# GitHub

Use this skill for consistent GitHub operations. Decide the profile at load time:

```
load the github skill with profile personal      ← for hobby projects
load the github skill with profile professional  ← for production projects
```

Default is `personal` if no profile is specified.

## Repo Creation

### Personal

```powershell
gh repo create <name> --public --description "Short one-line description" --source=. --remote=origin --push
```

- Public visibility
- No wiki, no projects
- Pages from `/docs` on master

### Professional

```powershell
gh repo create <name> --private --description "Short one-line description" --source=. --remote=origin --push --enable-issues --enable-wiki=false
```

- Private during active dev, switch to public on first stable release
- Issues enabled
- Branch protection for main branch (requires PR, requires approvals)
- Squash merge only

## Releases

### Personal

```powershell
gh release create vX.Y --title "Same as the repo description" --notes "Single-line summary of what it does"
```

- Single-line notes, no bullet list
- No changelog file required

### Professional

```powershell
gh release create vX.Y --title "Release X.Y" --notes-from-file CHANGES.md
```

- Notes from `CHANGES.md`
- GPG-signed tag
- CI builds draft release, manual publish after testing

## GitHub Pages

Same for both profiles:

```powershell
gh api repos/:owner/:repo/pages -X POST -f source.branch=master -f source.path=/docs
```

Custom domain: add `docs/CNAME` with the domain, then configure DNS CNAME.

## CI/CD

### Personal

- Pages build only (automatic with Jekyll)
- No additional actions

### Professional

- `.github/workflows/ci.yml`: test → lint → build → draft release
- `draft: true` on release action (manual publish)
- SLSA provenance on tagged releases
- `dependabot.yml` for dependency updates

## Repository Files

### Personal

- `README.md` — one paragraph, quick start
- `.gitignore`
- `docs/` — documentation site

### Professional

- `README.md` — features, install, usage, contributing
- `LICENSE.md`
- `CONTRIBUTING.md`
- `SECURITY.md` — vulnerability disclosure
- `CHANGES.md` — per-release changelog
- `CODE_OF_CONDUCT.md`
- `ISSUE_TEMPLATE/` — bug report, feature request
- `PULL_REQUEST_TEMPLATE.md`
- `.github/workflows/` — CI/CD
