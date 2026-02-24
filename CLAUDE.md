## The Crucible — Development Workflow

This project uses VDD (Verification-Driven Development) with The Crucible.
See `the-crucible.md` for the full spec.

### Session Start
Always begin with /prime.

### Development Cycle
1. /spec [description] — Define what to build
2. /plan — Decompose into Chainlink issues (routine versus critical)
3. /build — Execute (routine: fast path | critical: full Crucible plus Roast)
4. /status — Check progress

### Rules
- One task at a time. Max 5 files per task.
- All work tracked via Chainlink. No exceptions. Store the WHY.
- Routine: Builder -> Validator -> Commit.
- Critical: Test Writer -> Builder -> Validator -> ROAST_ME -> Commit.
- Builder runs its specific test file. Validator runs the full suite.
- 3 failed validation cycles means escalate to Human.
- Every successful cycle equals a git commit. No commit, no work done.

### Project Structure
- `.claude/` — Crucible agents, commands, hooks, context, skills, state.
- `.chainlink/` — Issue tracker DB, hook config, rules.
- `the-crucible.md` — The Crucible spec document.

### IMPORTANT: Chainlink Breadcrumb Discipline

**Every pipeline step MUST include a `chainlink session action` call. No exceptions. If you skip breadcrumbs, the work didn't happen.**

This applies to ALL work — whether invoked via `/build` or done manually. At minimum, log:
1. **Triage decision** — `chainlink session action "Triage: routine|critical for issue #N — [reason]"`
2. **Builder outcome** — `chainlink session action "Builder COMPLETE|BLOCKED: [what was built/changed and why]"`
3. **Validator verdict** — `chainlink session action "Validator PASS|FAIL iteration N: [summary]"`
4. **Task completion** — `chainlink session action "Task #N complete: [summary]"`

If the validator fails and the builder fixes, log BOTH the fail and the fix. The breadcrumb trail must capture the full reasoning chain — not just the final state.

Store **reasoning**, not just actions:
- Bad: "Updated weights"
- Good: "Changed boost_factor weight from 1.5 to 2.0. Sarcasmotron identified that low-boost items were ranked above high-relevance items in edge cases."
