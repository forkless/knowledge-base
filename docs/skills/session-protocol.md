← [Skills](../)

# Session Protocol & Governance

How this project is governed, how sessions work, and the rules that keep everything consistent.

## Authority

- The repository owner (forkless) has final authority on all decisions
- Suggestions are welcome at any time; the owner validates before implementation
- No change is too small to question, and no change ships without owner approval

## Session Protocol

### Initialization

1. **Full project scan** — understand the current state before making changes
2. **Check version control** — identify uncommitted work from prior sessions
3. **Load companion skills** — documentation, release-workflow, testing-fuzzing, privacy-security, ci-cd-pipeline

### Task Flow

1. **Impact analysis** — list every file and call site that needs to change before writing code
2. **One feature per cycle** — one logical change per commit
3. **Verification** — build, test, lint, and review before declaring done
4. **Draft cycle** — commit → push → CI builds draft → owner tests → publish

## Styling Rules

### Markdown

- No explicit `---` horizontal rules as section separators. Preserve structural `<hr>` from source material
- Single-line box-drawing only (`┌─┐│└┘├┤┬┴┼`). No double-line variants (`╔═╗║╚╝╠╣╦╩╬`)
- Verify diagram alignment: all lines same width, arrow connectors aligned, inner padding consistent
- Square bullets site-wide (via CSS `list-style: square`)
- Adjacent blockquotes merged into a single blockquote using `> - ` list syntax

### Code Blocks

- Commands only inside fences — labels and explanatory text stay outside
- Use language tags: ` ```powershell ` for Windows, ` ```bash ` for Linux, ` ```yaml ` / ` ```json ` / ` ```sql ` etc. for structured data
- Copy button added automatically via JS (Material Icons, dimmed by default)

### Color Palette

- Body background: `#f7f7f7`
- Headings: `#393e46`
- Links: `#e8a800` / hover `#d09000`
- Blockquote left border: `#d4763a`
- Blockquote bg: `#474747`, text: `#c0c0c0`
- Code blocks: bg `#ececec`, text `#474747`
- Footer/disclaimer bg: `#d4763a`, text: `#f7f7f7`

## Release & Versioning

### Version Bumps

| Bump | When |
|------|------|
| PATCH | Bug fix or small polish |
| MINOR | New feature or restructure |
| MAJOR | Breaking change (1.0+ only) |

### Release Checklist

- [ ] Impact analysis complete
- [ ] All tests pass
- [ ] Linter passes with zero warnings
- [ ] CHANGELOG.md has an entry
- [ ] Working tree is clean
- [ ] Release notes file updated

### Signing

- Commit with `--no-gpg-sign` in automation
- Maintainer amends with `--gpg-sign` before push
- `--force-with-lease` for amended commits or tag refreshes

## Privacy & Security

- No sensitive paths written to disk — user data is session-only when possible
- No scanning of user profiles or system directories beyond the current project
- All logged paths sanitized to strip user-identifiable prefixes
- Strip control characters from user-provided input before storage or logging
- No telemetry, no network connections beyond explicit tool use, no auto-updater
- No admin or root privileges required

## Communication

- Plain language over jargon
- When something breaks, state the failure and the next step — no over-apologizing
- Disagree openly but commit to decisions once they're made
- Questions are always welcome; the only bad question is the one not asked
