# Critical Paths — What Must Be Tested and Roasted

This file defines which areas of the project contain mission-critical logic. Work touching these paths MUST go through the full Crucible pipeline (test-writer -> builder -> validator -> Roast). The spec-analyst and /plan command should consult this file when classifying work as critical vs routine.

## Critical Logic

### 1. Safety Hooks
**Files:** `.claude/hooks/validate-scope.sh`, `.claude/hooks/post-edit-check.py`
**Why:** These are the guardrails that prevent destructive commands and enforce code quality. A bug here silently disables safety — the worst failure mode because it's invisible.
- Destructive command blocking patterns in `validate-scope.sh`
- Stub detection regex patterns in `post-edit-check.py`
- Linter invocation and error reporting logic

### 2. Pre-Tool Gate Hooks
**Files:** `.claude/hooks/work-check.py`, `.claude/hooks/pre-web-check.py`
**Why:** These enforce Chainlink discipline (no work without an issue) and web access safety. Bypassing them breaks the tracking guarantee.
- Issue existence validation before allowing writes
- Web request safety checks

### 3. Prompt Guard Hook
**Files:** `.claude/hooks/prompt-guard.py`
**Why:** Runs on every user prompt (`UserPromptSubmit`). Loads rules from `.chainlink/rules/` and injects behavioral guidance. A bug here could silently disable Chainlink discipline enforcement or allow unguarded prompts through.
- Rule loading and injection logic
- Behavioral guard generation

### 4. Session Lifecycle Hook
**Files:** `.claude/hooks/session-start.py`
**Why:** Runs on session start/resume (`SessionStart`). Auto-manages Chainlink sessions with stale-session detection (4-hour timeout). Incorrect behavior could lose session state or create orphaned sessions.
- Session auto-start and resume logic
- Stale session detection and cleanup

### 5. Pipeline Orchestration Logic
**Files:** `.claude/commands/build.md`
**Why:** The `/build` command controls triage routing (routine vs critical), the builder/validator loop, escalation after 3 failures, and ROAST_ME generation. Incorrect routing silently skips quality gates.
- Triage label checking and path selection
- Iteration counting and escalation logic
- ROAST_ME.md generation for critical tasks

### 6. Hook Configuration
**Files:** `.claude/settings.json`
**Why:** The settings file wires hooks to tool events. A misconfiguration disables hooks silently. Matcher patterns and command paths must be exact.
- Hook matcher patterns (which tools trigger which hooks)
- Command paths and timeout values

## Routine Work

The following are safe for the fast path (builder -> validator -> commit):

- **Agent definition files** (`.claude/agents/*.md`) — Markdown prompts, no executable logic
- **Command files** (`.claude/commands/*.md`) except `build.md` — Orchestration instructions, validated by pattern matching
- **Context files** (`.claude/context/*.md`) — Documentation, no execution
- **Chainlink configuration** (`.chainlink/hook-config.json`, `.chainlink/rules/`) — Declarative config
- **Documentation** (`CLAUDE.md`, `the-crucible.md`, `CHANGELOG.md`) — Prose

## Decision Guide

When classifying new work, ask:

1. **Does it execute?** Hooks and scripts execute. Markdown files are prompts. Executable code is more likely critical.
2. **What happens if it's subtly wrong?** If a silent failure disables safety or skips quality gates, it's critical. If it produces a bad prompt that a human will review, it's routine.
3. **Does it touch a security boundary?** Command blocking, web access gates, and file write guards are security boundaries. Always critical.
4. **Is it a new pattern or an existing one?** Adding a new hook type is critical. Adding another blocked command pattern to an existing hook is routine (the pattern is established).
