← [Skills](../)

# SQL Standards

## Style
- `UPPER_CASE` keywords: `SELECT`, `FROM`, `WHERE`, `JOIN`
- `snake_case` tables and columns
- 80 char line limit, break before keywords:

```sql
SELECT
    u.id,
    u.email,
    p.display_name
FROM
    users u
    INNER JOIN profiles p ON p.user_id = u.id
WHERE
    u.is_active = TRUE
ORDER BY
    u.created_at DESC;
```

## Naming
- Tables: plural nouns (`users`, `save_games`)
- PK: `id`. FK: `referenced_table_id` (`user_id`)
- Indexes: `idx_table_column` (`idx_users_email`)
- No Hungarian notation

## Queries
- Parameterized queries only (`WHERE id = ?` or `WHERE id = :id`)
- Never concatenate input into SQL
- `EXPLAIN ANALYZE` on hot paths. Prefer `JOIN` over subqueries

## Schema
- `NOT NULL` unless nulls are explicit. `created_at` / `updated_at` on every table
- `DECIMAL` for money, `UUID` for external IDs

## Migrations
- One file per change, timestamp-ordered. Append-only, never edit committed
- Each has both `up()` and `down()`

## Transactions
- `BEGIN` / `COMMIT` / `ROLLBACK` for multi-statement operations
- Keep transaction scope as short as possible

## Security
- `pgcrypto` or equivalent for db-side hashing
- Least privilege — never use owner account in application code
- Row-level security for multi-tenant tables
