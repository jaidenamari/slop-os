---
name: Database Migration
description: Execute and manage database migrations safely. Supports multiple ORMs through cookbooks (TypeORM, Drizzle, raw SQL, etc.).
---

# Database Migration

Execute and manage database migrations safely across different ORMs and migration systems.

## Purpose

This skill provides a standardized workflow for database migrations that adapts to whatever ORM or migration tool the project uses. It handles:

- Generating new migrations
- Running pending migrations
- Rolling back migrations
- Verifying migration state
- Troubleshooting migration issues

## Instructions

### Step 1: Detect Migration System

First, identify which migration system the project uses:

```
SCAN for indicators:
- package.json dependencies (typeorm, drizzle-orm, prisma, knex, etc.)
- Config files (ormconfig.*, drizzle.config.*, prisma/schema.prisma)
- Migration directories (migrations/, drizzle/, prisma/migrations/)
- Scripts in package.json (migrate, db:migrate, etc.)
```

### Step 2: Load Cookbook

Based on detection, load the appropriate cookbook:

| System | Cookbook |
|--------|----------|
| TypeORM | `cookbook/typeorm.md` |
| Drizzle | `cookbook/drizzle.md` |
| Prisma | `cookbook/prisma.md` |
| Raw SQL | `cookbook/raw-sql.md` |

```
READ cookbook/{detected-system}.md
FOLLOW system-specific commands and patterns
```

### Step 3: Execute Migration Workflow

The standard workflow (adapted per cookbook):

1. **Check current state** - List applied and pending migrations
2. **Backup reminder** - Warn user about production environments
3. **Run migration** - Execute the migration command
4. **Verify result** - Confirm schema changes applied correctly
5. **Update types** (if applicable) - Regenerate type definitions

### Step 4: Handle Failures

If migration fails:

1. Read error output carefully
2. Check for common issues (connection, permissions, conflicts)
3. Suggest rollback if partial application
4. Provide fix recommendations

## Optional: MCP Database Tools

If the project has a postgres MCP server configured, you can use it for:

- **Troubleshooting** - Running diagnostic queries directly
- **Verification** - Checking schema state after migrations
- **Data inspection** - Viewing affected data

MCP is NOT required for migrations - use the project's CLI tools instead.

```
# Only if postgres MCP available:
mcp_postgres__query("SELECT * FROM schema_migrations ORDER BY version")
```

## Workflow Variations

### Generate Migration

```
User: "Create a migration to add email column to users"

1. Load cookbook for detected ORM
2. Generate migration using ORM CLI (e.g., `typeorm migration:generate`)
3. Read generated migration file
4. Verify SQL is correct
5. Present to user for approval
```

### Run Migrations

```
User: "Run pending migrations"

1. Check pending migrations
2. Confirm with user (especially if production)
3. Execute migration command
4. Verify success
5. Report applied migrations
```

### Rollback Migration

```
User: "Rollback last migration"

1. Identify last applied migration
2. Check rollback capability (not all systems support this)
3. Execute rollback
4. Verify state
5. Report result
```

## Environment Awareness

Always check the target environment:

```
IF production environment:
  WARN user explicitly
  REQUIRE confirmation
  SUGGEST backup first
  RECOMMEND dry-run if available
```

## Examples

### Example 1: TypeORM Migration

```
User: "Add a new migration for soft delete on posts"

1. Detect: TypeORM (found typeorm in package.json)
2. Load: cookbook/typeorm.md
3. Generate: npx typeorm migration:generate -n AddPostsSoftDelete
4. Review generated SQL
5. Present to user
```

### Example 2: Drizzle Migration

```
User: "Run pending drizzle migrations"

1. Detect: Drizzle (found drizzle.config.ts)
2. Load: cookbook/drizzle.md
3. Check: npx drizzle-kit push:pg --dry-run
4. Confirm with user
5. Apply: npx drizzle-kit push:pg
6. Verify result
```

### Example 3: Troubleshoot with MCP

```
User: "Migration failed, check the schema"

1. If postgres MCP available:
   - Query information_schema for table structure
   - Check constraints and indexes
   - Compare against expected state
2. If no MCP:
   - Use ORM's introspection tools
   - Check migration log table
   - Suggest manual psql inspection
```

## Safety Checks

Before ANY migration:

- [ ] Confirmed target environment (dev/staging/prod)
- [ ] Checked for pending changes in codebase
- [ ] Verified database connection
- [ ] User acknowledged migration action

Before production migrations:

- [ ] Backup exists or acknowledged
- [ ] Dry-run completed (if available)
- [ ] Rollback plan ready
