# Raw SQL Migration Cookbook

Commands and patterns for raw SQL migrations (no ORM).

## Detection

Project uses raw SQL migrations if:
- No ORM detected (no typeorm, drizzle, prisma in package.json)
- `migrations/` directory with `.sql` files
- Custom migration runner in `package.json` scripts
- Database-specific tools (pg_migrate, dbmate, golang-migrate, etc.)

## Common Tools

### dbmate

```bash
# Check status
dbmate status

# Create migration
dbmate new add_users_table

# Apply migrations
dbmate up

# Rollback last migration
dbmate down

# Apply specific migration
dbmate up --step 1
```

Config: `DATABASE_URL` env var or `.dbmate.yml`

### golang-migrate

```bash
# Check status
migrate -database $DATABASE_URL -path migrations version

# Create migration
migrate create -ext sql -dir migrations -seq add_users_table

# Apply migrations
migrate -database $DATABASE_URL -path migrations up

# Rollback
migrate -database $DATABASE_URL -path migrations down 1
```

### Knex.js

```bash
# Check status
npx knex migrate:status

# Create migration
npx knex migrate:make add_users_table

# Apply migrations
npx knex migrate:latest

# Rollback
npx knex migrate:rollback
```

### psql (Manual)

```bash
# Apply single migration
psql $DATABASE_URL -f migrations/001_init.sql

# Check tables
psql $DATABASE_URL -c "\dt"
```

## Migration File Structure

### Numbered Migrations

```
migrations/
├── 001_init.sql
├── 002_add_users.sql
├── 003_add_posts.sql
```

### Timestamped Migrations

```
migrations/
├── 20231001120000_init.up.sql
├── 20231001120000_init.down.sql
├── 20231002150000_add_users.up.sql
├── 20231002150000_add_users.down.sql
```

## SQL Migration Template

### Up Migration

```sql
-- migrations/001_add_users.up.sql

BEGIN;

CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    name VARCHAR(255),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE INDEX idx_users_email ON users(email);

COMMIT;
```

### Down Migration

```sql
-- migrations/001_add_users.down.sql

BEGIN;

DROP INDEX IF EXISTS idx_users_email;
DROP TABLE IF EXISTS users;

COMMIT;
```

## Common Patterns

### Adding Column

```sql
ALTER TABLE users ADD COLUMN status VARCHAR(50) DEFAULT 'active';
```

### Adding Index

```sql
CREATE INDEX CONCURRENTLY idx_users_status ON users(status);
```

(Use CONCURRENTLY for large tables to avoid locking)

### Adding Foreign Key

```sql
ALTER TABLE posts 
ADD CONSTRAINT fk_posts_user 
FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE;
```

### Safe Column Type Change

```sql
-- Add new column
ALTER TABLE users ADD COLUMN email_new VARCHAR(500);

-- Copy data
UPDATE users SET email_new = email;

-- Drop old, rename new
ALTER TABLE users DROP COLUMN email;
ALTER TABLE users RENAME COLUMN email_new TO email;
```

## Migration Tracking

### Simple Version Table

```sql
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Check applied migrations
SELECT * FROM schema_migrations ORDER BY applied_at;

-- Record migration
INSERT INTO schema_migrations (version) VALUES ('001_add_users');
```

### With Checksum

```sql
CREATE TABLE IF NOT EXISTS schema_migrations (
    version VARCHAR(255) PRIMARY KEY,
    checksum VARCHAR(64),
    applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

## Troubleshooting

### Migration partially applied
```sql
-- Check what tables exist
SELECT tablename FROM pg_tables WHERE schemaname = 'public';

-- Check migration history
SELECT * FROM schema_migrations;

-- Manually mark as applied (after fixing)
INSERT INTO schema_migrations (version) VALUES ('003_broken_migration');
```

### Rollback without down migration
1. Write reverse SQL manually
2. Test on dev/staging first
3. Apply and update migration table

### Connection issues
```bash
# Test connection
psql $DATABASE_URL -c "SELECT 1"

# Check connection string format
# postgresql://user:password@host:port/database
```

## Environment Variables

Common patterns:
```bash
DATABASE_URL=postgresql://user:pass@localhost:5432/mydb
POSTGRES_HOST=localhost
POSTGRES_PORT=5432
POSTGRES_USER=myuser
POSTGRES_PASSWORD=mypass
POSTGRES_DB=mydb
```

## Project-Specific Notes

Look for:
- `Makefile` with migrate targets
- Shell scripts in `scripts/` or `bin/`
- Docker compose services for migrations
- CI/CD pipeline migration steps

```makefile
# Common Makefile patterns
migrate-up:
	migrate -database $(DATABASE_URL) -path migrations up

migrate-down:
	migrate -database $(DATABASE_URL) -path migrations down 1

migrate-create:
	migrate create -ext sql -dir migrations -seq $(name)
```
