# Patterns

This directory contains framework and architectural patterns used by the code-quality-review skill to validate implementations.

## Purpose

Patterns define **how** specific constructs should be implemented in this project. The review agent uses these patterns to validate that code follows established conventions.

## Structure

Each pattern file should include:

1. **When to Apply** - File patterns or code signatures that trigger this pattern
2. **Required Elements** - What must be present for compliance
3. **Anti-Patterns** - What to flag as violations
4. **Example** - Correct implementation

## Adding Patterns

When you introduce a new framework or establish a new convention:

1. Create `ai_docs/patterns/{pattern-name}.md`
2. Document the pattern following the template below
3. The review agent will automatically use it for validation

## Pattern Template

```markdown
# {Pattern Name}

{Brief description of what this pattern is for}

## When to Apply

- File patterns: `*Controller.ts`, `*.service.ts`
- Code signatures: `@Controller`, `class.*Service`

## Required Elements

1. {Element 1} - {Description}
2. {Element 2} - {Description}

## Anti-Patterns (Flag These)

- {Anti-pattern 1}
- {Anti-pattern 2}

## Example

\`\`\`typescript
// Correct implementation
{code example}
\`\`\`

## Validation Checklist

- [ ] {Check 1}
- [ ] {Check 2}
```

## Current Patterns

- `zod-validation.md` - Input validation with Zod schemas
- `result-pattern.md` - Error handling with Result<T, E>
- `repository-pattern.md` - Data access layer conventions

## Integration

The `pattern-validation.md` cookbook strategy:
1. Detects which patterns apply to changed files
2. Loads pattern definitions from this directory
3. Validates code against pattern requirements
4. Reports violations with specific remediation
