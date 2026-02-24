## The Crucible — Development Workflow

This project uses VDD (Verification-Driven Development) with The Crucible agentic harness.
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
- `slop1.0/` — Legacy. Ignore.
- `.claude/` — Crucible agents, commands, hooks, context, skills, state.
- `.chainlink/` — Issue tracker DB, hook config, rules.
- `the-crucible.md` — The Crucible spec document.

### Chainlink Breadcrumb Discipline
Store **reasoning**, not just actions:
- Bad: "Updated weights"
- Good: "Changed boost_factor weight from 1.5 to 2.0. Sarcasmotron identified that low-boost items were ranked above high-relevance items in edge cases."
