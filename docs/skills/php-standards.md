← [Skills](../)

# PHP Standards

## Version
- Target PHP 8.2+, `declare(strict_types=1);`, `<?php` only

## Style (PSR-12)
- 4-space indent, `PascalCase` classes, `camelCase` methods, `UPPER_SNAKE_CASE` constants
- One `use` per line, namespace before imports

## Types
- Typed properties and return types everywhere
- `readonly` for DTOs, `enum` for fixed sets, no dynamic properties

## Errors
- Specific catch types, never bare `Exception`. Log with context.

## Dependencies
- Composer, pin major versions. Prefer PSR-compliant packages.

## Security
- Parameterized SQL, `password_hash()`/`verify()`, validate at boundary

## Testing
- PHPUnit, one test class per source class, data providers for parameters
