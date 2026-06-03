# Release Workflow

Versioning, release checklist, signing, and push conventions.

## Versioning

| Bump | When | Example |
|------|------|---------|
| PATCH | Bug fix or small polish after a release | v0.3.1 → v0.3.2 |
| MINOR | New feature or significant restructure | v0.3.x → v0.4.0 |
| MAJOR | Breaking change (1.0+ only) | 1.0.0 → 2.0.0 |

- Version in the project manifest matches the latest release tag
- Tags are created at release time, not per-commit
- Multiple commits can happen between tags

## Draft Release Cycle

```
commit → push → tag v0.x.y → CI builds draft → user tests → publish
```

No release goes live without the user testing the draft first.

## Release Checklist

Before signing a release tag:

- [ ] Impact analysis completed — all call sites for new/changed functions
- [ ] All tests pass
- [ ] Linter passes with zero warnings
- [ ] CHANGELOG.md has an entry
- [ ] SECURITY.md Supported Versions updated for the new version
- [ ] Working tree is clean — no uncommitted changes
- [ ] Release notes file is updated for the new version

After CI completes:

- [ ] Download draft binaries from the releases page
- [ ] Test on target platform — basic workflow, key features
- [ ] Click **Publish release** on the hosting platform when satisfied

## Signing & Push

- Commit with `--no-gpg-sign` (avoids GPG passphrase hang in non-interactive terminals)
- Maintainer amends with `--gpg-sign` before push
- Normal push for fast-forward commits
- `--force-with-lease` for amended commits or tag refreshes
- If force-pushing, delete old tag and re-tag after the new commit lands

## Release Notes

- Release notes file contains only the current version's changes
- Historical release notes on the platform are cleaned per-release
