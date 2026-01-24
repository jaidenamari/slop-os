# Pattern Validation Strategy

Validates that framework and architectural patterns are correctly applied.

## Purpose

Ensures code follows established patterns for the frameworks in use. Patterns are stored in `ai_docs/patterns/` and define how specific constructs should be implemented.

## Inputs Required

- `CHANGED_FILES`: Files to validate
- `PROJECT_RULES`: From `.cursor/rules/`
- `PATTERNS_DIR`: `ai_docs/patterns/` containing framework patterns

## Workflow

### Step 1: Detect Applicable Patterns

Analyze changed files to determine which patterns apply:

```
FILE: src/controllers/UserController.ts
DETECTED:
- Controller pattern (has @Controller decorator)
- Route handlers (has @Get, @Post, etc.)
- Dependency injection (constructor params)

APPLICABLE_PATTERNS:
- ai_docs/patterns/tsed-controller.md
- ai_docs/patterns/dependency-injection.md
```

### Step 2: Load Pattern Definitions

```
READ ai_docs/patterns/{pattern-name}.md

Extract:
- Required elements (decorators, imports, structure)
- Anti-patterns to flag
- Example of correct usage
```

### Step 3: Validate Against Patterns

For each file + applicable pattern:

```
PATTERN: tsed-controller
REQUIREMENTS:
- Must have @Controller decorator with route prefix
- Must inject services via constructor
- Route handlers must have proper decorators
- Must use DTOs for request/response typing
- Must have Zod validation on inputs

CHECK each requirement against actual code
FLAG deviations with specific line references
```

### Step 4: Cross-File Pattern Validation

Some patterns span multiple files:

```
PATTERN: repository-pattern
FILES_INVOLVED:
- Repository class (data access)
- Service class (business logic)  
- Controller (HTTP layer)

VALIDATE:
- Controller does NOT directly access repository
- Service is injected into controller
- Repository is injected into service
- No business logic in controller
```

## Pattern Detection Heuristics

| File Pattern | Likely Patterns to Validate |
|--------------|----------------------------|
| `*Controller.ts` | tsed-controller, route-validation, dto-usage |
| `*Service.ts` | service-layer, error-handling, transaction |
| `*Repository.ts` | repository-pattern, query-builder |
| `*.model.ts` | entity-definition, validation-decorators |
| `use*.ts` (hooks) | react-hooks, data-fetching |
| `*.test.ts` | testing-patterns, mocking |

## Output Format

```markdown
## Pattern Validation Report

### Patterns Evaluated
- {pattern-name}: {file count} files

### Violations

#### {pattern-name}
| File | Line | Issue | Expected |
|------|------|-------|----------|
| {file} | {line} | {what's wrong} | {what it should be} |

### Correct Usage
✓ {file} correctly implements {pattern}

### Suggestions
- {file}: Consider {improvement} for better adherence to {pattern}
```

## Enforcement

- **BLOCKING** if pattern is fundamentally broken (e.g., controller accessing DB directly)
- **BLOCKING** if validation is missing on user inputs
- **ADVISORY** for style-level pattern deviations

## Example

```
File: src/controllers/OrderController.ts

Pattern: tsed-controller
✓ Has @Controller("/orders") decorator
✓ Injects OrderService via constructor
✗ Line 45: @Post handler missing @BodyParams validation
✗ Line 52: Returns raw entity, should use ResponseDTO
✓ Uses async/await correctly

Pattern: zod-validation  
✗ Line 45: No Zod schema validation on request body
  Expected: const validated = CreateOrderSchema.parse(body)
  
Status: 2 BLOCKING violations
```
