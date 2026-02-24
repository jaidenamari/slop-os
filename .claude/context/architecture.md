# Architecture — slop-os / The Crucible

This file describes the system architecture of slop-os, a Verification-Driven Development (VDD) framework for Claude Code. Agents and commands consult this file to understand how the system fits together.

## Three Pillars

| Pillar | Tool | Role |
|--------|------|------|
| **The Forge** | Claude Code | Orchestrates agents, executes pipelines, writes code, runs mechanical validation. |
| **The Ledger** | Chainlink | Local-first issue tracker. Stores session state, decision reasoning, dependencies, breadcrumbs. |
| **The Sieve** | Sarcasmotron (Gemini Gem) | Cross-model adversarial reviewer. Roasts code for intent and edge cases. |

The developer sits at the center, mediating between them. Maturity level: **L3 — Orchestrated Pipelines**.

## Execution Model

### Pipeline Flow

```
/spec → spec-analyst → spec.md → [HUMAN GATE]
/plan → scout + decomposition → Chainlink issues (routine|critical) → [HUMAN GATE]
/build → triage check →
  routine:  builder → validator → commit
  critical: test-writer → builder → validator → ROAST_ME.md → [HUMAN BRIDGES ROAST] → commit
```

### Agent Communication

Sub-agents run in isolated 200k context windows. The orchestrator spawns an agent with a prompt, receives a text summary back. No shared memory between agents — the orchestrator holds summaries and passes relevant context forward. Files (Chainlink DB, spec.md) handle cross-session persistence only.

### Triage Routing

Every Chainlink issue is tagged `routine` or `critical` during `/plan`:

- **Routine** — Bug fixes, config, CSS, simple CRUD, docs. Fast path: builder → validator → commit.
- **Critical** — Business logic, auth, ranking, security, math. Full Crucible: test-writer → builder → validator → Roast → commit.

Consult `critical-paths.md` for which files/areas are critical.

## Directory Layout

```
.claude/
  agents/          Sub-agent configs (scout, builder, validator, spec-analyst, test-writer, meta-agent)
  commands/        User-facing /commands (prime, spec, plan, build, status, review, scout, new-agent)
  hooks/           Safety and quality gates (PreToolUse, PostToolUse, UserPromptSubmit, SessionStart)
  context/         Strategic documentation (this file, critical-paths, testing-strategy, sarcasmotron-setup)
  skills/          On-demand knowledge libraries (loaded dynamically, not always in context)
  mcp/             MCP servers (safe-fetch-server.py)
  state/           Transient state (ROAST_ME.md, generated per critical task)
  settings.json    Hook wiring configuration

.chainlink/
  issues.db        SQLite database (local, gitignored)
  hook-config.json Tracking mode (strict/normal/relaxed), blocked commands, allowed prefixes
  rules/           Behavioral rules injected by prompt-guard.py (global, project, language-specific)

tests/             Project test infrastructure
```

## Agent Registry

| Agent | Model | Role | Tools |
|-------|-------|------|-------|
| **scout** | haiku | Read-only codebase explorer | Read, Grep, Glob, Bash (plan mode) |
| **spec-analyst** | opus | Spec writer with triage classification | Read, Grep, Glob, Bash (plan mode) |
| **test-writer** | sonnet | Red-phase TDD for critical logic | Read, Grep, Glob, Bash, Write, Edit |
| **builder** | opus | Single-task implementer | Read, Grep, Glob, Bash, Write, Edit |
| **validator** | opus | Adversarial mechanical reviewer | Read, Grep, Glob, Bash (plan mode) |
| **meta-agent** | opus | Agent architect — generates new agents | Write, WebFetch, Firecrawl, MultiEdit |

Model principle: Opus for reasoning and precision (spec analysis, validation, building, agent design). Sonnet for balanced execution (testing). Haiku for speed (scouting).

## Hook Architecture

Hooks enforce safety and quality at tool-use boundaries:

```
PreToolUse
  WebFetch|WebSearch  → pre-web-check.py    (RFIP injection defense)
  Write|Edit|Bash     → work-check.py       (Chainlink issue enforcement)
  Bash                → validate-scope.sh   (destructive command blocking)

PostToolUse
  Write|Edit          → post-edit-check.py  (stub detection, linting)
  Write|Edit          → post-write-lint.sh  (shellcheck for shell scripts)

UserPromptSubmit
  (all prompts)       → prompt-guard.py     (behavioral rule injection)

SessionStart
  startup|resume      → session-start.py    (session lifecycle, stale detection)
```

### Safety Layers

1. **Destructive command blocking** — validate-scope.sh blocks rm -rf, DROP TABLE, force push, etc. Exit 2 stops the tool call.
2. **Issue tracking enforcement** — work-check.py blocks Write/Edit/Bash without an active Chainlink issue (in strict mode).
3. **Web injection defense** — pre-web-check.py implements RFIP to prevent prompt injection via fetched content.
4. **Code quality gates** — post-edit-check.py detects stubs (TODO, pass, unimplemented!) and runs language-specific linters.
5. **Behavioral rules** — prompt-guard.py loads rules from .chainlink/rules/ and injects them into every prompt.
6. **Session lifecycle** — session-start.py auto-manages sessions with 4-hour stale timeout.

## Chainlink Integration

Chainlink is the memory layer. It tracks:

- **Issues** — What work exists, priority, labels (routine/critical), dependencies, parent/child relationships.
- **Sessions** — Which issue is active, breadcrumb trail of actions, handoff notes.
- **Comments** — The WHY behind decisions, not just the WHAT.

Key commands: `chainlink session start`, `chainlink quick "<task>"`, `chainlink session work <id>`, `chainlink session action "<breadcrumb>"`, `chainlink close <id>`.

Tracking mode (strict/normal/relaxed) is set in `.chainlink/hook-config.json` and enforced by work-check.py.

## Convergence and Escalation

- Builder/validator loop runs up to 3 iterations. On the 3rd failure, the system escalates to the human with full history.
- For critical tasks, the Roast loop (Sarcasmotron) runs until ZERO-SLOP verdict or hallucination detected.
- Every successful cycle produces a git commit. No commit = no work done.

## Key Design Decisions

1. **Agents are stateless.** Each invocation gets a fresh context window. State lives in Chainlink and files.
2. **Hooks are the immune system.** They run automatically and cannot be bypassed by agents. Safety is structural, not behavioral.
3. **Triage prevents waste.** Not every task needs Opus-level reasoning or cross-model roasting. Routine work takes the fast path.
4. **The human is the arbiter.** Between Claude and Sarcasmotron, the developer judges what's real. No automated merge of conflicting feedback.
5. **Breadcrumbs survive context compression.** Session-start.py re-injects context on resume. Chainlink stores the reasoning chain.
