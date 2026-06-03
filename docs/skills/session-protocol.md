← [Skills](../)

# Session Protocol

How to structure and execute each development session efficiently.

## Initialization

1. **Full project scan first** — read the build file, all source files, tests, docs. Ensures the full codebase is understood before making changes.
2. **Check version control status** — identify any uncommitted work from prior sessions.
3. **Load companion skills** — documentation, release-workflow, testing-fuzzing, privacy-security, ci-cd-pipeline.

## Task Protocol

1. **Impact analysis before code** — list every file and call site that needs to change. Present for validation before writing code.
2. **One feature per cycle** — one logical change per commit. Batch docs, changelog, and version metadata with the feature.
3. **Call site audit on completion** — verify every reference is updated. Build + test + lint before declaring done.
4. **Draft release cycle** — commit → push → tag → CI builds draft → user tests → publish. Never ship without draft testing.
