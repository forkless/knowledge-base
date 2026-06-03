# Testing & Fuzzing

Testing conventions and fuzzing strategy.

## Integration Tests

**Test patterns to follow:**
- Use temporary directories for all file-based tests
- Test both success and failure paths
- Test round-trips: create → process → verify content matches
- Test edge cases: empty inputs, truncated data, missing files

**Where tests live:**
- `tests/` — cross-module integration tests
- `src/` — unit tests in language-standard test modules
- `fuzz/fuzz_targets/` — fuzz targets

## Fuzz Targets

Fuzzing is for code that parses **untrusted binary input**.

**When to add a fuzz target:**
- Custom binary format parsers
- Archive round-trips (create archive from fuzzed inputs → restore → compare)
- Not needed for deterministic operations or wrapping established libraries

**Requirements:**
- Fuzzing requires a nightly toolchain for sanitizer instrumentation
- The project must have a fuzz harness (e.g. cargo-fuzz, libfuzzer, oss-fuzz)

## Coverage Requirements

- Every new feature ships with integration or unit tests
- Fuzz targets for binary parsers and archive round-trips only
- All tests must pass before every commit
- Linter must pass with zero warnings
- Doc coverage check must pass (if implemented)
