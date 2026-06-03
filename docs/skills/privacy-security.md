# Privacy & Security

Privacy-first design principles and security practices.

## Privacy Principles

- **No sensitive paths written to disk** — user data is session-only when possible
- **No scanning of user profiles or system directories** beyond the current user
- **All logged paths sanitized** to strip user-identifiable prefixes
- **User consent tracked via sentinel file**, not a config file with user data

## Input Handling

- Strip control characters from user-provided input before it reaches config files, logs, or the filesystem — prevents injection and log forgery
- Validate and sanitize all external input before processing

## Security Practices

- `deny(unsafe_code)` enabled where the language supports it — zero unsafe
- Dependency auditing and license checks in CI for every commit
- GPG-signed release tags with build provenance attestation
- Vulnerability disclosure policy documented in the repository

## What We Avoid

- No telemetry, no network connections, no auto-updater
- No admin or root privileges required — runs in user context
- No third-party services in the shipped binary
