---
name: Code Quality Review
description: Contextual code quality review triggered after agent completes source code changes. Validates against specs, patterns, and project standards.
---

# Code Quality Review

Execute a contextual code review that validates changes against the design spec, framework patterns, and project standards.

## Purpose

This skill creates a closed loop between the code agent and review agent:

```
quick-plan → specs/ → build (code agent) → [stop hook] → review (this skill) → fix if needed → done
```

The review is contextual - it knows what was supposed to be built (from specs) and validates the implementation matches the design while following project conventions.

## Instructions

### Prerequisites

- Spec file in `specs/` (created by `quick-plan.md`)
- Project rules in `.cursor/rules/`
- Patterns in `ai_docs/patterns/` (optional, enhances validation)
- Git repository with trackable changes

### Trigger Conditions

1. **Automatic** - `stop` hook fires when code agent completes source code changes
2. **Manual** - User invokes `/review` command
3. **Escalated** - User invokes with `@adversary` for rigorous review

### Input Context

When triggered by hook, read context from `.cursor/review-context/{sessionId}.json`:

```json
{
  "sessionId": "abc123",
  "userPrompt": "original request",
  "specFile": "specs/feature-name.md",
  "sourceFilesChanged": ["src/file1.ts", "src/file2.ts"],
  "enforcement": {
    "critical": "blocking",
    "high": "blocking",
    "medium": "advisory",
    "low": "advisory"
  }
}
```

## Workflow

### Phase 1: Context Gathering

1. READ review context from `.cursor/review-context/` (if hook-triggered)
2. READ spec file from `specs/` (identified in context or most recent)
3. RUN `git diff --name-only` to confirm changed files
4. READ `.cursor/rules/project_rules.md` for project standards
5. LIST `ai_docs/patterns/` to identify available patterns

### Phase 2: Execute Strategies

Execute cookbook strategies in order. Each strategy can produce blocking or advisory findings.

```
STRATEGIES = [
  "cookbook/spec-compliance.md",      # Did we build what was designed?
  "cookbook/pattern-validation.md",    # Are patterns correctly applied?
  "cookbook/standards-enforcement.md", # Do we follow project rules?
  "cookbook/security-baseline.md"      # Basic security checks
]

for strategy in STRATEGIES:
  READ strategy
  EXECUTE against changed files
  COLLECT findings
```

#### Strategy Selection

Not all strategies run every time:

| Trigger | Spec Compliance | Patterns | Standards | Security |
|---------|-----------------|----------|-----------|----------|
| Hook (standard) | ✓ if spec exists | ✓ | ✓ | ✓ |
| Manual (quick) | - | - | ✓ | - |
| Manual (standard) | ✓ | ✓ | ✓ | ✓ |
| Manual (deep) | ✓ | ✓ | ✓ | ✓ + adversary |

### Phase 3: Enforcement Decision

```
BLOCKING_ISSUES = findings where severity in [critical, high]
ADVISORY_ISSUES = findings where severity in [medium, low]

if BLOCKING_ISSUES:
  STATUS = "FAIL"
  ACTION = "Code agent must fix before completion"
else if ADVISORY_ISSUES:
  STATUS = "NEEDS_ATTENTION"  
  ACTION = "User decides whether to address"
else:
  STATUS = "PASS"
  ACTION = "Proceed"
```

### Phase 4: Report & Loop

1. WRITE report to `ai_docs/reviews/{ISO_DATE}-{feature}.md`
2. IF blocking issues AND triggered by hook:
   - Signal code agent to fix issues
   - Re-run review after fixes
3. IF advisory only:
   - Present to user for decision
4. CLEAN UP `.cursor/review-context/{sessionId}.json`

## Integration with Other Agents

### Code Agent Coordination

When blocking issues found, the review agent communicates back:

```markdown
## Review Failed - Action Required

The following issues must be fixed:

1. `src/controllers/UserController.ts:45` - Missing Zod validation
2. `src/services/UserService.ts:23` - Function exceeds 50 lines

Please fix these issues. Review will re-run automatically.
```

### Adversary Escalation

For deep mode or when security-sensitive code detected:

```
INVOKE @adversary with:
  FEATURE_CONTEXT: {summary of changes from spec}
  BASELINE_TRUTH: {project rules + security requirements}
  
MERGE adversary findings into report
```

## Cookbook Strategies

Each strategy is a self-contained review recipe:

| Strategy | Purpose | Blocking If |
|----------|---------|-------------|
| `spec-compliance.md` | Validates implementation matches spec | Success criteria not met |
| `pattern-validation.md` | Validates framework patterns | Pattern fundamentally broken |
| `standards-enforcement.md` | Enforces project rules | Type errors, lint errors, missing validation |
| `security-baseline.md` | Basic security checks | Secrets, injection, missing auth |

## Report Format

```markdown
# Code Quality Review

**Date**: {ISO_DATE}
**Spec**: {spec filename or "manual review"}
**Status**: {PASS | FAIL | NEEDS_ATTENTION}
**Files Reviewed**: {count}

## Summary

{One paragraph summary of findings}

## Blocking Issues

{Must be fixed before completion}

| Severity | File | Line | Issue | Strategy |
|----------|------|------|-------|----------|
| Critical | {file} | {line} | {issue} | {which strategy found it} |

## Advisory Issues

{Recommended but not blocking}

| Severity | File | Line | Issue |
|----------|------|------|-------|
| Medium | {file} | {line} | {issue} |

## Strategy Results

### Spec Compliance
{summary}

### Pattern Validation  
{summary}

### Standards Enforcement
{summary}

### Security Baseline
{summary}

## Recommendation

{What should happen next - fix issues, proceed, escalate to adversary}
```

## Examples

### Example 1: Hook-Triggered Review After Feature Build

```
Context: Code agent built user dashboard chart per specs/user-dashboard-chart.md

1. Hook fires, creates review context
2. Review agent reads context, loads spec
3. Runs spec-compliance: ✓ All components implemented
4. Runs pattern-validation: ✗ React hook not memoized
5. Runs standards-enforcement: ✓ Types correct, lint clean
6. Runs security-baseline: ✓ No issues

Result: NEEDS_ATTENTION (1 advisory)
Action: Present to user - "useMemo recommended for performance"
```

### Example 2: Blocking Issues Trigger Fix Loop

```
Context: Code agent built payment endpoint

1. Review runs after code agent completes
2. Runs security-baseline: ✗ BLOCKING - Missing input validation
3. Runs standards-enforcement: ✗ BLOCKING - Zod schema not used

Result: FAIL (2 blocking)
Action: Signal code agent to fix, wait for completion, re-review
```

### Example 3: Manual Deep Review with Adversary

```
User: "/review deep"

1. Load all changed files
2. Run all strategies
3. INVOKE @adversary for rigorous critique
4. Merge adversary findings
5. Generate comprehensive report

Result: Combined findings from automated + adversarial review
```
