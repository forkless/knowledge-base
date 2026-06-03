← [Skills](../)

# Rust Standards

Coding conventions and patterns for the NotAlterra project.

## Error Handling

- Use `anyhow::Result` for fallible functions — no custom error types
- `anyhow::bail!` for early returns with context
- `.with_context(|| format!(...))` on `Result` from external crates
- Avoid `unwrap()` and `expect()` outside of tests and examples
- Use `let _ = fallible_fn()` when deliberately ignoring errors

## File I/O

- Prefer `std::fs` convenience functions for simple operations (`fs::read()`, `fs::write()`, `fs::read_dir()`)
- Use `PathBuf` for owned paths, `&Path` for borrowed references
- Validate paths early with `path.exists()` before operations
- Use `saturating_sub` for all arithmetic that could underflow

## String Handling

- Use `format!()` for construction, avoid `+` concatenation
- Use `to_string_lossy()` for OsStr → String conversion
- Strip control characters from user input before storage or logging

## Data Structures

- Prefer `Vec` over linked lists or custom containers
- Use `HashSet` for deduplication
- Use `Option<T>` for nullable values — never `null` or sentinel values
- Use `struct` with named fields for complex return types
- Derive `Debug, Clone` on all data structures, `Default` where meaningful

## Pattern: Property Extraction (GVAS parser)

All four extractors follow the same pattern:
1. Scan for property name using `windows(target.len()).position()`
2. Validate the FName header (length dword + null terminator)
3. Skip past the property type name
4. Validate bounds before every index access
5. Return `Option` or `Result` — never panic

When adding a new property type, follow this exact pattern and add a bounds check on every array access.

## Pattern: TUI Dialogs

All dialogs follow the same structure:
1. Define popup area with `centered_rect_size()` or `centered_rect()`
2. Render `Clear` widget, then a bordered `Block`
3. Compute `inner` area with margin
4. Render title, body, buttons in sequence
5. Call `draw_whale_separator(f, bar, app)` at the bottom

## Pattern: Menu Actions

All menu actions:
1. Validate preconditions (save folder set, backup exists)
2. Show status/spinner if the operation takes time
3. Call through to `ops::*` for actual file operations
4. Log via `guard::log_action()` with sanitized paths
5. Show result dialog (success or error)
6. Refresh dashboard stats

## Clippy

- `-D warnings` enforced in CI — no exceptions
- Fix lints immediately when CI catches new ones
- Common lints that have fired: `collapsible_match`, `manual_is_multiple_of`, `empty_line_after_doc_comments`, `needless_borrows_for_generic_args`

## Dependencies

- Prefer crates with 50M+ downloads for core functionality
- Avoid platform-specific FFI — prefer pure Rust where possible
- Keep dependency count minimal — each new crate is a review point
- Run `cargo audit` and `cargo deny` before each release
