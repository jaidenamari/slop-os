# Drizzle Migration Cookbook

Commands and patterns for Drizzle ORM migrations.

## Detection

Project uses Drizzle if:
- `drizzle-orm` in package.json dependencies
- `drizzle.config.ts` or `drizzle.config.js` exists
- `drizzle/` directory with migration files

## Configuration

Config location: `drizzle.config.ts`

```typescript
import { defineConfig } from 'drizzle-kit';

export default defineConfig({
  schema: './src/db/schema.ts',
  out: './drizzle',
  driver: 'pg',
  dbCredentials: {
    connectionString: process.env.DATABASE_URL!,
  },
});
```

## Commands

### Check Migration Status

```bash
# List migrations and their status
npx drizzle-kit check

# Or check generated SQL without applying
npx drizzle-kit generate --dry-run
```

### Generate Migration

```bash
# Generate SQL migration files from schema changes
npx drizzle-kit generate

# With custom name
npx drizzle-kit generate --name add_users_table
```

Generated files location: `drizzle/` directory (or configured `out` path)

### Apply Migrations

Drizzle has two modes:

#### Push Mode (Development)
```bash
# Push schema directly to database (no migration files)
npx drizzle-kit push
```

#### Migrate Mode (Production)
```bash
# Apply migration files
npx drizzle-kit migrate

# Or via drizzle-orm migrate function in code
```

### Introspect Existing Database

```bash
# Generate schema from existing database
npx drizzle-kit introspect
```

## Migration File Structure

Drizzle generates SQL files:

```
drizzle/
├── 0000_initial.sql
├── 0001_add_users_email.sql
├── meta/
│   ├── _journal.json
│   └── 0000_snapshot.json
```

SQL migration example:
```sql
ALTER TABLE "users" ADD COLUMN "email" varchar(255);
```

Journal tracks applied migrations:
```json
{
  "entries": [
    { "idx": 0, "when": 1234567890, "tag": "0000_initial" }
  ]
}
```

## Schema Definition

Drizzle schemas are TypeScript:

```typescript
import { pgTable, serial, varchar, timestamp } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  id: serial('id').primaryKey(),
  name: varchar('name', { length: 255 }).notNull(),
  email: varchar('email', { length: 255 }).unique(),
  createdAt: timestamp('created_at').defaultNow(),
});
```

## Common Patterns

### Adding Column

In schema file:
```typescript
export const users = pgTable('users', {
  // existing columns...
  status: varchar('status', { length: 50 }).default('active'),
});
```

Then generate: `npx drizzle-kit generate`

### Adding Index

```typescript
import { index } from 'drizzle-orm/pg-core';

export const users = pgTable('users', {
  // columns...
}, (table) => ({
  emailIdx: index('email_idx').on(table.email),
}));
```

### Adding Relation

```typescript
import { relations } from 'drizzle-orm';

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));
```

## Troubleshooting

### "No schema changes detected"
- Ensure schema file path is correct in drizzle.config.ts
- Check that you've saved the schema file
- Run `npx drizzle-kit check` to see current state

### Push vs Migrate confusion
- **Push**: Direct schema sync, good for development
- **Migrate**: Migration files, required for production
- Use migrate for any shared/production database

### Type generation
```bash
# Regenerate TypeScript types after schema changes
npx drizzle-kit generate
```

## Rollback

Drizzle doesn't have built-in rollback. Options:

1. **Manual SQL**: Write reverse migration
2. **Snapshot restore**: Restore database from backup
3. **Down migration**: Create new migration that undoes changes

## Project-Specific Notes

Check for project-specific scripts in `package.json`:
```json
{
  "scripts": {
    "db:generate": "drizzle-kit generate",
    "db:push": "drizzle-kit push",
    "db:migrate": "drizzle-kit migrate",
    "db:studio": "drizzle-kit studio"
  }
}
```

Drizzle Studio for visual inspection:
```bash
npx drizzle-kit studio
```
