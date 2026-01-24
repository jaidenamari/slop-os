# Prisma Migration Cookbook

Commands and patterns for Prisma migrations.

## Detection

Project uses Prisma if:
- `prisma` in package.json devDependencies
- `@prisma/client` in dependencies
- `prisma/schema.prisma` exists
- `prisma/migrations/` directory

## Configuration

Schema location: `prisma/schema.prisma`

```prisma
datasource db {
  provider = "postgresql"
  url      = env("DATABASE_URL")
}

generator client {
  provider = "prisma-client-js"
}

model User {
  id    Int     @id @default(autoincrement())
  email String  @unique
  name  String?
}
```

## Commands

### Check Migration Status

```bash
# Show migration status
npx prisma migrate status

# Show pending migrations
npx prisma migrate diff --from-schema-datamodel prisma/schema.prisma --to-schema-datasource prisma/schema.prisma
```

### Generate Migration

```bash
# Create migration from schema changes (development)
npx prisma migrate dev --name add_user_email

# Create migration without applying (for review)
npx prisma migrate dev --create-only --name add_user_email
```

### Apply Migrations

```bash
# Development (interactive, resets if needed)
npx prisma migrate dev

# Production (non-interactive, fails on issues)
npx prisma migrate deploy
```

### Reset Database

```bash
# Reset and re-apply all migrations (DESTRUCTIVE)
npx prisma migrate reset
```

## Migration File Structure

```
prisma/
├── schema.prisma
└── migrations/
    ├── 20231001120000_init/
    │   └── migration.sql
    ├── 20231002150000_add_email/
    │   └── migration.sql
    └── migration_lock.toml
```

SQL migration example:
```sql
-- CreateTable
CREATE TABLE "User" (
    "id" SERIAL NOT NULL,
    "email" TEXT NOT NULL,
    "name" TEXT,
    CONSTRAINT "User_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "User_email_key" ON "User"("email");
```

## Schema Definition

```prisma
model User {
  id        Int      @id @default(autoincrement())
  email     String   @unique
  name      String?
  posts     Post[]
  createdAt DateTime @default(now())
}

model Post {
  id       Int    @id @default(autoincrement())
  title    String
  author   User   @relation(fields: [authorId], references: [id])
  authorId Int
}
```

## Common Patterns

### Adding Column

In schema.prisma:
```prisma
model User {
  // existing fields...
  status String @default("active")
}
```

Then: `npx prisma migrate dev --name add_user_status`

### Adding Index

```prisma
model User {
  email String

  @@index([email])
}
```

### Adding Relation

```prisma
model User {
  posts Post[]
}

model Post {
  author   User @relation(fields: [authorId], references: [id])
  authorId Int
}
```

## Troubleshooting

### "Drift detected"
Database schema doesn't match migration history:
```bash
# Check what's different
npx prisma migrate diff --from-schema-datasource prisma/schema.prisma --to-schema-datamodel prisma/schema.prisma

# Options:
# 1. Create migration to capture drift: npx prisma migrate dev
# 2. Reset if dev environment: npx prisma migrate reset
# 3. Baseline if existing production: npx prisma migrate resolve --applied "migration_name"
```

### "Migration failed to apply"
```bash
# Mark migration as applied (if manually fixed)
npx prisma migrate resolve --applied "20231001120000_migration_name"

# Mark as rolled back
npx prisma migrate resolve --rolled-back "20231001120000_migration_name"
```

### Client out of sync
```bash
# Regenerate Prisma Client after schema changes
npx prisma generate
```

## Rollback

Prisma doesn't have built-in rollback. Options:

1. **Create reverse migration**: `npx prisma migrate dev --name revert_xyz`
2. **Manual SQL**: Edit migration file before applying
3. **Reset** (dev only): `npx prisma migrate reset`

## Type Generation

```bash
# Generate TypeScript types from schema
npx prisma generate

# Introspect existing database to schema
npx prisma db pull
```

## Project-Specific Notes

Check for project-specific scripts in `package.json`:
```json
{
  "scripts": {
    "db:migrate": "prisma migrate dev",
    "db:deploy": "prisma migrate deploy",
    "db:reset": "prisma migrate reset",
    "db:studio": "prisma studio",
    "db:generate": "prisma generate"
  }
}
```

Prisma Studio for visual inspection:
```bash
npx prisma studio
```
