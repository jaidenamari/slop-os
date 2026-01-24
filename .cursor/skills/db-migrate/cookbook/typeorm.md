# TypeORM Migration Cookbook

Commands and patterns for TypeORM migrations.

## Detection

Project uses TypeORM if:
- `typeorm` in package.json dependencies
- `ormconfig.js`, `ormconfig.ts`, or `data-source.ts` exists
- `migrations/` directory with timestamp-prefixed `.ts` files

## Configuration

Typical config locations:
- `ormconfig.js` / `ormconfig.ts` (legacy)
- `src/data-source.ts` (modern)
- Environment variables (`TYPEORM_*`)

## Commands

### Check Migration Status

```bash
# Using TypeORM CLI
npx typeorm migration:show -d src/data-source.ts

# Or via npm script (check package.json)
npm run typeorm migration:show
```

### Generate Migration

```bash
# Auto-generate from entity changes
npx typeorm migration:generate -d src/data-source.ts -n MigrationName

# Create empty migration
npx typeorm migration:create -n MigrationName
```

Generated file location: `migrations/{timestamp}-{MigrationName}.ts`

### Run Migrations

```bash
# Run all pending
npx typeorm migration:run -d src/data-source.ts

# Via npm script
npm run typeorm migration:run
```

### Rollback Migration

```bash
# Revert last migration
npx typeorm migration:revert -d src/data-source.ts
```

## Migration File Structure

```typescript
import { MigrationInterface, QueryRunner } from "typeorm";

export class AddUserEmailColumn1234567890123 implements MigrationInterface {
    name = 'AddUserEmailColumn1234567890123'

    public async up(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "user" ADD "email" varchar(255)`);
    }

    public async down(queryRunner: QueryRunner): Promise<void> {
        await queryRunner.query(`ALTER TABLE "user" DROP COLUMN "email"`);
    }
}
```

## Migration Table

TypeORM tracks migrations in: `migrations` table (or configured name)

Query to check state:
```sql
SELECT * FROM migrations ORDER BY id DESC;
```

## Common Patterns

### Adding Column

```typescript
await queryRunner.query(`ALTER TABLE "users" ADD "status" varchar(50) DEFAULT 'active'`);
```

### Adding Index

```typescript
await queryRunner.query(`CREATE INDEX "IDX_users_email" ON "users" ("email")`);
```

### Adding Foreign Key

```typescript
await queryRunner.query(`
  ALTER TABLE "posts" 
  ADD CONSTRAINT "FK_posts_user" 
  FOREIGN KEY ("userId") REFERENCES "users"("id") ON DELETE CASCADE
`);
```

## Troubleshooting

### "No migrations are pending"
- Check entity changes are saved
- Ensure synchronize is false in config
- Verify data-source path is correct

### "Migration already exists"
- Check migrations table for duplicates
- May need to manually remove failed migration record

### Connection errors
- Verify DATABASE_URL or TYPEORM_* env vars
- Check data-source.ts configuration
- Test connection: `npx typeorm query "SELECT 1" -d src/data-source.ts`

## Project-Specific Notes

Check for project-specific scripts in `package.json`:
```json
{
  "scripts": {
    "migration:generate": "typeorm migration:generate -d src/data-source.ts -n",
    "migration:run": "typeorm migration:run -d src/data-source.ts",
    "migration:revert": "typeorm migration:revert -d src/data-source.ts"
  }
}
```

Use project scripts when available - they may include required flags or setup.
