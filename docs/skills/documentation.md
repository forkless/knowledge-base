← [Skills](../)

# Documentation

## File Placement

| File | Location | Purpose |
|------|----------|--------|
| `README.md` | Root | Entry point — features, install, quick start |
| `LICENSE.md` | Root | Project license (MIT, Apache, etc.) |
| `CHANGELOG.md` | Root | Release history, version per entry |
| `CONTRIBUTING.md` | Root | How to contribute, run locally, submit PRs |
| `SECURITY.md` | Root | Vulnerability disclosure policy |
| `GOVERNANCE.md` | `docs/` | Roadmap, release process, bus factor |
| `KNOWN_ISSUES.md` | `docs/` | Known bugs and limitations |
| `DECISIONS.md` | `docs/` | Architecture rationale, trade-offs |
| `AUDIT.md` | `docs/` | Third-party dependency audit notes |
| `CODE_SIGNING_POLICY.md` | `docs/` | Signing key management expectations |
| `_release.md` | Root | Current release notes body (CI references it) |
| API docs | `docs/` | Module guides, technical references |

## Doc Comment Standards

- Every public function must have a doc comment
- Each comment explains *what* the function does, *why* it exists, and *what edge cases* it handles
- No "Internal helper" or "see module-level docs" placeholders
- Language-standard doc format

## Changelog Format

```
## [v0.x.y] — YYYY-MM-DD

### Added
- New features

### Fixed
- Bug fixes

### Changed
- Behavior changes, refactors

### Removed
- Features removed

### Notes
- Operational notes (git resets, CI issues, etc.)
```

## Release Notes (`_release.md`)

- Contains only the current version changes
- Replaced entirely per release, not appended
- Must be at root because the CI workflow references it by path
