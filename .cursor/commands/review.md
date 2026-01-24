---
description: Invoke the code quality review skill to validate changes against specs, patterns, and standards
argument-hint: [mode: quick|standard|deep] [scope: staged|last-commit|branch]
---

# Review

Execute the code-quality-review skill to validate changes contextually.

## Variables

- `MODE`: ${1:-standard} - Review intensity: quick, standard, or deep
- `SCOPE`: ${2:-staged} - What to review: staged, last-commit, branch, or file paths

## Instructions

This command invokes the review agent to execute the code-quality-review skill. The review:

1. Validates implementation against the spec (if one exists in `specs/`)
2. Checks framework patterns are correctly applied (from `ai_docs/patterns/`)
3. Enforces project standards (from `.cursor/rules/`)
4. Performs security baseline checks

## Modes

| Mode | Strategies | Use When |
|------|------------|----------|
| quick | Standards only | Fast check, lint/type errors |
| standard | All four strategies | Normal review |
| deep | All + @adversary | Critical code, security-sensitive |

## Workflow

1. INVOKE `@review-agent` with MODE and SCOPE
2. Agent executes `.cursor/skills/code-quality-review/SKILL.md`
3. Agent applies cookbook strategies from `cookbook/`
4. IF blocking issues: Agent loops to fix or reports for manual fix
5. IF advisory issues: Presents to user for decision
6. WRITES report to `ai_docs/reviews/`

## Examples

```
/review                    # Standard review of staged changes
/review quick              # Quick lint/type check only
/review deep branch        # Deep review with adversary on all branch changes
/review standard src/api/  # Standard review of specific directory
```

## Report

Output includes:
- Verdict (PASS / FAIL / NEEDS_ATTENTION)
- Blocking issues that must be fixed
- Advisory issues for user decision
- Path to full report
