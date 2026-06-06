← [Skills](../)

# CI/CD Pipeline Setup

Blueprint for setting up a GitHub Actions CI/CD pipeline with checks, builds, draft releases, and supply-chain provenance.

## Overview

The pipeline is organized as a single workflow file (`.github/workflows/ci.yml`) with jobs that run in dependency order. Tag pushes trigger the build+release path; branch pushes and PRs trigger only the check path.

## Job Structure

```
check (every push)
  ├── unit tests
  ├── linter
  ├── dependency audit
  └── documentation
          │
pages (master only) - deploy API docs
          │
build (tags only)
  ├── compile for all targets
  ├── package into archives
  └── upload as workflow artifacts
          │
provenance (tags only) - SLSA attestation
          │
release (tags only) - create draft release with all artifacts
```

## Check Job

Runs on every push and pull request. Should include:

- **Check** - verify the project compiles
- **Tests** - run the full test suite
- **Linter** - enforce zero warnings
- **Dependency audit** - check for known vulnerabilities
- **Documentation** - generate and upload API docs (master only)

```yaml
check:
  runs-on: ubuntu-latest
  steps:
    - uses: actions/checkout@v4
    - uses: dtolnay/rust-toolchain@stable
    - run: cargo check --workspace
    - run: cargo test --workspace
    - run: cargo clippy --workspace -- -D warnings
    - run: cargo doc --no-deps
```

## Build & Release Job

Only runs on tag pushes matching a version pattern (e.g. `v*`).

- Builds for all target platforms
- Creates release archives (tar.gz, zip)
- Generates SHA256 hashes of all artifacts
- Uploads archives as workflow artifacts
- Sets `draft: true` so releases require manual publishing

```yaml
build:
  needs: check
  if: startsWith(github.ref, 'refs/tags/v')
  outputs:
    hashes: ${{ steps.hash.outputs.hashes }}
  steps:
    - uses: actions/checkout@v4
    - run: <build commands for each target>
    - name: Package
      run: <create archives>
    - name: Upload artifacts
      uses: actions/upload-artifact@v4
      with:
        path: builds/
```

## Provenance (SLSA)

Uses the SLSA v3 generator to attest that release artifacts were built by the CI pipeline from a specific commit.

```yaml
provenance:
  needs: build
  if: startsWith(github.ref, 'refs/tags/v')
  uses: slsa-framework/slsa-github-generator/.github/workflows/generator_generic_slsa3.yml@v2.0.0
  with:
    base64-subjects: "${{ needs.build.outputs.hashes }}"
    upload-assets: false
```

## Draft Release Job

Creates a draft release after build + provenance both complete. Downloads the binary artifacts and provenance attestation, then uploads them together.

```yaml
release:
  needs: [build, provenance]
  if: startsWith(github.ref, 'refs/tags/v')
  steps:
    - uses: actions/download-artifact@v4
    - uses: softprops/action-gh-release@v2
      with:
        files: <artifact paths>
        body_path: _release.md
        draft: true
```

## Guardrails

- Releases are always **drafts** - the maintainer tests before publishing
- Provenance runs as a separate job to avoid interfering with the release
- `upload-assets: false` on the SLSA generator - let the release job handle all uploads
- SHA256 hashes are generated in the build job and passed to provenance

## Key Actions

| Action | Purpose |
|--------|---------|
| `actions/checkout@v4` | Check out source code |
| `actions/upload-artifact@v4` | Store build artifacts between jobs |
| `actions/download-artifact@v4` | Retrieve artifacts in downstream jobs |
| `softprops/action-gh-release@v2` | Create releases (supports `draft: true`) |
| `slsa-framework/slsa-github-generator` | Generate SLSA v3 provenance |
| `dtolnay/rust-toolchain@stable` | Install the language toolchain |

## First-Time Setup

1. Create `.github/workflows/ci.yml` with the job structure above
2. Create `_release.md` with the initial release notes template
3. Enable GitHub Pages if using API docs (Settings → Pages → GitHub Actions)
4. Create a signed tag and push to verify the pipeline
5. Test the draft → publish cycle end-to-end
