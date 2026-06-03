← [Skills](../)

# Python Standards

## Version
- Target Python 3.11+

## Style (PEP 8)
- 4-space indent, 88 char line limit (Black default)
- `snake_case` functions/vars, `UPPER_SNAKE_CASE` constants, `PascalCase` classes
- Type hints on all function signatures

## Imports
- Standard lib -> third-party -> local, blank line between groups
- Absolute imports preferred

## Types
- `mypy --strict` in CI. `dataclass` over dicts for structured data
- `Enum` or `StrEnum` for fixed sets. `T | None` in 3.10+

## Errors
- Catch specific types, never bare `except:`. `contextlib.suppress` for ignored errors
- Log with `logging.getLogger(__name__)`, never `print`

## Dependencies
- `pip freeze > requirements.txt` or Poetry/pyproject.toml
- Pin major versions, `~=` for compatible releases

## Testing
- `pytest` with `pytest-cov`. Tests in `tests/` mirroring `src/`
- Fixtures for setup, parametrize for data-driven tests
- Mock external IO, test business logic directly

## CLI
- `argparse` or `click` for CLI tools. `--verbose`/`-v` and `--quiet`/`-q`
