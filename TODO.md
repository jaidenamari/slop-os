# Slop OS - Development Status

This document tracks the status of features in this generalized AI toolkit.

---

## Architecture Philosophy

This toolkit is designed to be **project-agnostic**. Skills use **cookbooks** to adapt to different technologies:

- **db-migrate** → cookbooks for TypeORM, Drizzle, Prisma, raw SQL
- **test-writing** → cookbooks for Jest, Vitest, Playwright, Mocha
- **error-log-analysis** → cookbooks for Sentry, local logs, Docker, stack traces

Agents are **focused** and invoke skills when they need specialized workflows.

---

## Completed Features ✅

### Skills

| Skill | Description | Cookbooks |
|-------|-------------|-----------|
| `code-quality-review` | Validates code against specs, patterns, standards | spec-compliance, pattern-validation, standards-enforcement, security-baseline |
| `db-migrate` | ORM-agnostic database migrations | TypeORM, Drizzle, Prisma, raw-sql |
| `test-writing` | Framework-agnostic test generation | Jest, Vitest, Playwright, Mocha |
| `error-log-analysis` | Error diagnosis from various sources | Sentry, local-logs, stack-trace, docker-logs |

### Agents

| Agent | Purpose |
|-------|---------|
| `review-agent` | Code quality review, invokes code-quality-review skill |
| `security-auditor` | Security-focused review, uses security-baseline cookbook |
| `test-writer` | Test generation, invokes test-writing skill |
| `research-agent` | Web research and documentation gathering |
| `adversary` | Rigorous critique for deep reviews |
| `docs-scraper` | Documentation fetching and processing |
| `aws-inspector` | AWS infrastructure analysis |

### Hooks

| Hook | Purpose |
|------|---------|
| `format.sh` | Auto-format/lint edited files using project tooling |
| `review-on-complete.sh` | Trigger review when code agent completes |

### Directories

- `ai_docs/research/` - Research output directory
- `ai_docs/reviews/` - Code review reports
- `ai_docs/patterns/` - Reusable code patterns

---

## Remaining Work

### Medium Priority

#### `plan.md` Command ⚠️ INCOMPLETE

**Status**: Missing frontmatter
**Issue**: Lacks proper YAML frontmatter (no `---` delimiters).

**Action**: Add frontmatter and differentiate from `quick-plan.md`.

---

#### Context Bundles ⚠️ CONCEPT ONLY

**Status**: `.cursor/agents/context_bundles/todo.md` describes a concept but isn't implemented.

**Proposed features**:
- Structured session ID tracking
- Operation logging (read, write, prompt, tool calls)
- Context sharing between agents

**Action**: Either implement or move to planning docs.

---

### Low Priority / Future Enhancements

#### Additional Test Cookbooks

Could add cookbooks for:
- Cypress (E2E)
- Testing Library patterns
- Python pytest
- Go testing

#### Additional ORM Cookbooks

Could add cookbooks for:
- MikroORM
- Sequelize
- Knex.js
- SQLAlchemy

#### Error Analysis Enhancements

Could add:
- CloudWatch integration
- Datadog integration
- Log pattern learning

---

## Skill Development Guidelines

When adding a new skill:

1. **Create SKILL.md** with:
   - Frontmatter (name, description)
   - Purpose and scope
   - Detection logic (how to identify which cookbook to use)
   - Generic workflow (applies across all cookbooks)
   - Examples

2. **Create cookbooks** for each variation:
   - Detection criteria
   - Specific commands
   - Common patterns
   - Troubleshooting

3. **Reference from agents** - Agents invoke skills, not the other way around

4. **MCPs are optional** - Skills should work without MCPs; MCPs enhance capabilities (like database queries for troubleshooting)

---

## Testing Checklist

When completing an item:
1. Test the feature manually
2. Update this document
3. Update README.md if usage changed
4. Commit with descriptive message
