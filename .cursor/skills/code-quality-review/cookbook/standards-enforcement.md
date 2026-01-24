# Standards Enforcement Strategy

Enforces project-specific coding standards and conventions.

## Purpose

Validates code against the project's defined standards in `.cursor/rules/`. Users can't always be trusted to enforce standards - this strategy provides automated enforcement.

## Inputs Required

- `CHANGED_FILES`: Files to validate
- `PROJECT_RULES`: `.cursor/rules/project_rules.md` and any file-specific rules
- `PROJECT_CONTEXT`: Tech stack, conventions from rules

## Workflow

### Step 1: Load Project Rules

```
READ .cursor/rules/project_rules.md
READ .cursor/rules/*.md (any additional rule files)

Extract:
- Tooling requirements (bun vs npm, uv vs pip)
- Code style rules (function length, component size)
- Architecture rules (where files should live)
- Type safety requirements
- Error handling patterns
```

### Step 2: Static Analysis

Run project-configured linters and type checkers:

```bash
# TypeScript type checking
npx tsc --noEmit

# Linting (based on project tooling)
bun run lint

# Python (if applicable)
uv run ruff check .
uv run mypy . --ignore-missing-imports
```

Capture any errors/warnings.

### Step 3: Rule-Based Validation

For each rule in project_rules.md:

```
RULE: "Keep functions under 50 lines"
CHECK: Parse each function, count lines
FLAG: Functions exceeding limit

RULE: "Keep components and files under 500 lines"
CHECK: Count lines per file
FLAG: Files exceeding limit

RULE: "Use Result<T, E> pattern for error handling"
CHECK: Look for try/catch that doesn't use Result
FLAG: Non-compliant error handling

RULE: "Validate inputs using Zod schemas"
CHECK: API handlers have Zod validation
FLAG: Handlers without input validation

RULE: "For python types, never use Dict, always use Pydantic"
CHECK: Python files using Dict type hint
FLAG: Dict usage, suggest Pydantic model
```

### Step 4: Convention Checks

```
NAMING:
- Files: kebab-case or PascalCase (components)
- Variables: camelCase
- Constants: UPPER_SNAKE_CASE
- Classes: PascalCase

IMPORTS:
- Use path aliases (@/...)
- No circular dependencies
- Proper ordering (external, internal, relative)

FILE LOCATION:
- Components in apps/frontend/
- API code in apps/backend/
- Shared types in appropriate location
```

### Step 5: Documentation Requirements

```
CHECK:
- Public APIs have JSDoc
- Complex functions have explanatory comments
- No commented-out code blocks
- No TODO comments without issue reference
```

## Output Format

```markdown
## Standards Enforcement Report

### Static Analysis
- TypeScript: {PASS/FAIL} - {error count} errors
- Linting: {PASS/FAIL} - {error count} errors, {warning count} warnings

### Rule Violations

#### Code Quality
| Rule | File | Line | Issue |
|------|------|------|-------|
| Function length | {file} | {line} | {X} lines (max 50) |
| File length | {file} | - | {X} lines (max 500) |

#### Type Safety
| File | Line | Issue |
|------|------|-------|
| {file} | {line} | Missing Zod validation |
| {file} | {line} | Using `any` type |

#### Conventions
| Category | File | Issue |
|----------|------|-------|
| Naming | {file} | {incorrect name} should be {correct} |
| Location | {file} | Should be in {correct path} |

### Passing Checks
✓ All imports use path aliases
✓ No circular dependencies detected
✓ Error handling follows Result pattern
```

## Enforcement

- **BLOCKING** if type errors exist
- **BLOCKING** if lint errors (not warnings)
- **BLOCKING** if security-related rules violated (Zod validation, etc.)
- **ADVISORY** for style/convention issues

## Example

```
Project: Slop OS (TypeScript + Python)

Static Analysis:
✓ TypeScript: PASS (0 errors)
✗ Linting: FAIL (2 errors, 5 warnings)

Rule Violations:
| Rule | File | Issue |
|------|------|-------|
| Function length | src/services/OrderService.ts:142 | processOrder is 78 lines |
| Zod validation | src/api/users.ts:23 | POST handler missing schema validation |
| Dict usage | apps/backend/models.py:15 | Use Pydantic model instead of Dict |

Conventions:
✓ File naming correct
✓ Import aliases used
✗ src/utils/helpers.ts - Should be in shared/ if used by both apps

Status: 2 BLOCKING (lint errors, missing validation), 2 ADVISORY
```
