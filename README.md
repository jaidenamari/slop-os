# Slop OS

An agentic wrapper layer for codebases that leverages Cursor's agent infrastructure to provide focused context management, automated reviews, and structured workflows.

## Architecture Overview

```
User Input → Commands → Agents → Skills
                ↓          ↓
              Hooks      Patterns
                ↓          ↓
              Rules    ai_docs/
```

## Tool Types

| Type | Location | Invoked By | Purpose |
|------|----------|------------|---------|
| **Commands** | `.cursor/commands/` | User (`/command`) | User-initiated workflows |
| **Agents** | `.cursor/agents/` | User or Agent (`@agent`) | Specialized AI personas |
| **Skills** | `.cursor/skills/` | Agent (auto-loaded) | Reusable capabilities |
| **Hooks** | `.cursor/hooks/` | System (automatic) | Event-triggered actions |
| **Rules** | `.cursor/rules/` | System (always applied) | Project standards |
| **Patterns** | `ai_docs/patterns/` | Skills (validation) | Framework conventions |

---

## Commands (User-Invoked)

Commands are user-initiated workflows. Invoke with `/command-name` in chat.

| Command | Description | Usage |
|---------|-------------|-------|
| `/build` | Implement a plan from specs/ | `/build specs/feature-name.md` |
| `/quick-plan` | Create detailed implementation plan | `/quick-plan add user auth` |
| `/plan` | Create basic implementation plan | `/plan feature description` |
| `/review` | Run code quality review | `/review [mode] [scope]` |
| `/prime` | Get codebase overview | `/prime` |
| `/load-ai-docs` | Fetch external documentation | `/load-ai-docs` |

### Common Workflow

```
/quick-plan add dashboard chart  →  specs/dashboard-chart.md
/build specs/dashboard-chart.md  →  implementation
/review                          →  validation
```

---

## Agents (User or Agent Invoked)

Agents are specialized AI personas. Invoke with `@agent-name` mention.

### Review & Quality

| Agent | Model | Purpose | Invoke |
|-------|-------|---------|--------|
| `@review-agent` | opus | Validates code against specs, patterns, standards | Auto (hook) or `@review-agent` |
| `@adversary` | gemini-3-pro | Rigorous philosophical critique | `@adversary` for deep reviews |
| `@code-reviewer` | inherit | Basic security-focused review | `@code-reviewer` |
| `@security-auditor` | inherit | Security vulnerability audit | `@security-auditor` |

### Development Support

| Agent | Model | Purpose | Invoke |
|-------|-------|---------|--------|
| `@test-writer` | sonnet | Generate vitest test suites | `@test-writer src/module.ts` |
| `@docs-scraper` | haiku | Fetch and summarize documentation | `@docs-scraper [url]` |
| `@research-agent` | sonnet | Web research and documentation gathering | `@research-agent [topic]` |
| `@aws-inspector` | sonnet | Read-only AWS configuration inspection | `@aws-inspector [error]` |

---

## Skills (Agent Auto-Loaded)

Skills are reusable capabilities automatically loaded when relevant. Agents reference them; users don't invoke directly.

| Skill | Trigger | Purpose |
|-------|---------|---------|
| `code-quality-review` | After source code changes | Validate against specs, patterns, rules |
| `db-migrate` | Database operations | Execute migrations via MCP |

### code-quality-review

Executes four strategies from `cookbook/`:
1. **spec-compliance** - Does implementation match the spec?
2. **pattern-validation** - Are framework patterns correct?
3. **standards-enforcement** - Are project rules followed?
4. **security-baseline** - Basic security checks

---

## Hooks (Automatic)

Hooks fire automatically on system events. Configured in `.cursor/hooks.json`.

| Hook | Event | Purpose |
|------|-------|---------|
| `format.sh` | `afterFileEdit` | Auto-format edited files |
| `review-on-complete.sh` | `stop` | Trigger review when agent completes |

### Review Loop

When an agent completes source code changes:
1. `stop` hook fires → `review-on-complete.sh`
2. Creates context in `.cursor/review-context/`
3. Triggers `@review-agent`
4. If blocking issues → code agent fixes → re-review
5. If clean → workflow complete

---

## Rules (Always Applied)

Rules in `.cursor/rules/` are always applied to agent context.

- `project_rules.md` - Project standards, tooling, guidelines

---

## Patterns (Validation Reference)

Patterns in `ai_docs/patterns/` define how to implement specific constructs. Used by `pattern-validation` strategy.

| Pattern | Validates |
|---------|-----------|
| `zod-validation.md` | Input validation with Zod schemas |
| `result-pattern.md` | Error handling with `Result<T, E>` |
| `repository-pattern.md` | Data access layer conventions |

---

## Directory Structure

```
.cursor/
├── agents/           # AI personas (@mention invocable)
│   └── context_bundles/  # Shared context for agents (WIP)
├── commands/         # User workflows (/command invocable)
├── hooks/            # Event scripts
├── hooks.json        # Hook configuration
├── rules/            # Always-applied standards
├── skills/           # Reusable capabilities
│   ├── code-quality-review/
│   │   ├── SKILL.md
│   │   ├── cookbook/     # Review strategies
│   │   └── prompts/      # Review prompts
│   └── db-migrate/
└── mcp.json          # MCP server configuration

ai_docs/
├── patterns/         # Framework conventions
├── reviews/          # Generated review reports (output)
└── README.md         # Documentation URLs to fetch

specs/                # Implementation plans (generated by /quick-plan)
```

---

## Quick Reference

### Start a Feature
```
/quick-plan [feature description]
/build specs/[generated-spec].md
```

### Manual Review
```
/review              # Standard review of staged changes
/review quick        # Fast lint/type check
/review deep branch  # Deep review with @adversary
```

### Get Help
```
/prime               # Understand the codebase
@research-agent      # Research external topics
@docs-scraper        # Fetch specific documentation
```