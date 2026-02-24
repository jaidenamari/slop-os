# Testing Strategy — What to Test, What Not To

This file defines the testing philosophy for the project. The test-writer agent and the `/plan` command consult this file when deciding what gets tested. Tests are strategic, not exhaustive. Only mission-critical business logic gets tested. This is NOT a project that tests everything — it tests what matters.

## Testing Philosophy

Tests exist to catch bugs that would cause **silent, dangerous failures**. A bug in a ranking algorithm silently returns wrong results. A bug in an auth check silently grants access. A bug in a markdown prompt produces bad output that a human will see and catch. The first two get tests. The third does not.

The cost of a test is not just writing it — it is maintaining it through every refactor. Tests on stable business logic pay for themselves. Tests on boilerplate create drag. Every test must justify its existence by protecting a path where failure is both likely and damaging.

## What Gets Tested

Logic that would cause silent, dangerous failures if wrong. Consult **`critical-paths.md`** for the specific file list and rationale.

### Business Logic
- Ranking, scoring, and calculation algorithms
- Weight-based prioritization and tiebreakers
- Any function where incorrect output looks plausible (wrong results, not crashes)

### Security Boundaries
- Authentication and authorization checks
- Access control enforcement
- Input validation that prevents injection or privilege escalation

### Data Integrity
- Data transforms and serialization/deserialization
- State machine transitions and lifecycle management
- Migration logic that alters persistent data

### Hook Logic
- Safety guardrails (destructive command blocking, scope validation)
- Gate enforcement (issue existence checks, pre-tool guards)
- Regex patterns that detect stubs, blocked commands, or violations
- Rule loading and behavioral injection logic

## What Does NOT Get Tested

The test-writer explicitly skips these. The `/plan` command tags work touching only these areas as `routine`, which means no test-writer invocation.

- **Markdown prompt files** — Agent definitions, command files, context docs. Not executable.
- **Configuration and declarative files** — JSON config, YAML, Chainlink rules. Validated by schema or by the tools that consume them.
- **Simple CRUD operations** — Straightforward create/read/update/delete with no business logic.
- **CSS, UI layout, and styling** — Visual correctness is verified by humans, not assertions.
- **Boilerplate and glue code** — Imports, re-exports, type aliases, trivial wrappers.
- **Documentation** — README, CHANGELOG, inline comments. Prose is not testable.
- **Dependency updates** — Version bumps with no logic changes.

## TDD Approach

This project uses **red-phase TDD for critical logic only**. The workflow is strict:

1. **Test-writer** creates failing tests (red phase). Tests define the behavioral contract: inputs, outputs, error conditions, and state transitions. Tests MUST fail when first written — a passing test from the test-writer is a bug.
2. **Builder** writes minimum code to make the tests pass (green phase). The builder runs the specific test file for its task to confirm green.
3. **Validator** runs the full test suite, type checker, and linter to confirm nothing else broke.

Tests verify **behavior** (inputs, outputs, contracts), not **implementation details** (private methods, internal state, call order). A correct refactor should never break a test. If it does, the test was testing the wrong thing.

## Test Conventions

Practical guidance for the **test-writer** agent:

### Placement
- Detect and match existing project conventions first. If tests already exist somewhere, put new tests in the same place.
- If no convention exists: place test files next to the code they test, with a `test_` prefix (Python) or `.test.` infix (JS/TS).
- For hook scripts in `.claude/hooks/`, place tests in a `tests/` directory at the project root or adjacent to the hooks directory.

### Naming
- Test file names must clearly indicate what they test: `test_validate_scope.py`, `post-edit-check.test.ts`, not `test1.py`.
- Test function/method names describe the behavior being verified: `test_blocks_rm_rf_command`, `test_returns_zero_for_empty_input`, not `test_function_works`.

### Framework
- Use the project's existing test framework. Detect it from existing test files, `package.json`, `pyproject.toml`, `Cargo.toml`, or equivalent.
- If no framework exists, use the language's standard library test runner (Python `unittest`/`pytest`, Rust `#[test]`, etc.).
- Do NOT impose a new framework without evidence that it matches the project.

### Focus
- Maximum 3 test files per task. If more are needed, report BLOCKED.
- Each test file has a clear, narrow purpose. No mega test files.
- Test the critical path, not every permutation. Prioritize: happy path, primary error path, the edge case most likely to cause silent failure.

## Who Runs What

Responsibilities are strict and non-overlapping:

| Role | Responsibility |
|------|---------------|
| **Test-writer** | Creates new test files for critical logic. Confirms they fail (red phase). Does NOT write production code. Does NOT modify existing tests. |
| **Builder** | Runs the specific test file for its task. Confirms tests pass (green phase). Does NOT create or modify tests. |
| **Validator** | Runs the full test suite, type checker, and linter. Reports pass/fail. Does NOT modify code or tests. |

Nobody else touches tests. The `/plan` command sets the `routine` or `critical` label per issue, which determines whether the test-writer is invoked at all.
