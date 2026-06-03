← [Skills](../)

# Bash Standards

Compatibility and readability conventions for shell scripts.

## Shebang

- Use `#!/usr/bin/env bash` for portability, not hardcoded `/bin/bash`
- Use `#!/bin/sh` only when the script genuinely works with POSIX sh

## Strict Mode

Start scripts with:

```bash
#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'
```

- `-e` — exit on error
- `-u` — error on unset variables
- `-o pipefail` — fail if any command in a pipeline fails
- `IFS` — only split on newlines and tabs, avoids word-splitting surprises

## Style

- **2-space indent** (4-space is too deep for shell, especially with nested conditionals)
- `snake_case` for variables and functions
- `UPPER_SNAKE_CASE` for environment variables and readonly globals
- Opening braces on the same line as the keyword:

```bash
if [[ -f "$file" ]]; then
    echo "exists"
fi

for item in "${list[@]}"; do
    process "$item"
done
```

## Conditionals

- Use `[[ ]]` over `[ ]` — fewer quoting issues, more features (regex, pattern matching)
- Quote all variable expansions: `"$var"`, not `$var`
- Quote command substitutions: `"$(command)"`

## Functions

- Declare with `name()` { ... } — no `function` keyword (POSIX-compatible)
- Keep functions small, one task each
- Use `local` for all function-scoped variables:

```bash
greet() {
    local name="$1"
    echo "Hello, $name"
}
```

## Error Handling

- Print error messages to stderr:

```bash
die() {
    echo "$*" >&2
    exit 1
}
```

- Check command exit codes explicitly when `set -e` isn't enough
- Use `trap` for cleanup on exit:

```bash
cleanup() {
    rm -f "$tmpfile"
}
trap cleanup EXIT
```

## Input Validation

- Check argument count before accessing positional params:

```bash
if [[ $# -lt 1 ]]; then
    die "Usage: $0 <file>"
fi
```

- Validate file existence before reading/writing
- Use `${var:-default}` for optional variables with fallbacks

## Output

- `printf` over `echo` for anything beyond plain strings (more portable)
- Use heredocs for multi-line blocks:

```bash
cat <<EOF > config.ini
[default]
path=$target_dir
mode=0755
EOF
```

## Organization

```
#!/usr/bin/env bash
set -euo pipefail

# ── Constants ──────────────────────────────
readonly APP_NAME="my-tool"
readonly CONFIG_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/$APP_NAME"

# ── Helpers ────────────────────────────────
die() { echo "$*" >&2; exit 1; }

# ── Main ───────────────────────────────────
main() { ... }
main "$@"
```

- Constants at the top, then helpers, then the main function
- `main "$@"` at the bottom — keeps the global scope clean
- Section comments with dividers for longer scripts
