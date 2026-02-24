Getting to the point where an LLm can self review it is critical to have some adversarial friction. Generally it is best to have a review agent not be the same model as the model writing code.

In order to chain this one could use Claude and a Gemini Gem that runs the adversary. This is ideal to ensure that the code base is being rigorously reviewed, and doesn't fall into one models bias.

https://gist.github.com/dollspace-gay/45c95ebfb5a3a3bae84d8bebd662cc25


# The Crucible — Agentic VDD for Claude Code

> Build with Claude. Roast with Sarcasmotron. Track with Chainlink. Ship Zero-Slop.

---

## Table of Contents

1. [What This Is](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#1-what-this-is)
2. [The Three Pillars](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#2-the-three-pillars)
3. [Maturity Levels](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#3-maturity-levels)
4. [Architecture](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#4-architecture)
5. [The VDD Loop](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#5-the-vdd-loop)
6. [Agent Definitions](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#6-agent-definitions)
7. [Commands](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#7-commands)
8. [Hooks](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#8-hooks)
9. [Chainlink Integration](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#9-chainlink-integration)
10. [Sarcasmotron Setup](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#10-sarcasmotron-setup)
11. [Skills and Context](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#11-skills-and-context)
12. [The Four Layers](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#12-the-four-layers)
13. [Anti-Patterns](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#13-anti-patterns)
14. [Implementation Roadmap](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#14-implementation-roadmap)
15. [File Tree](https://claude.ai/chat/6c6b956e-ea57-4f0d-a133-4458184dbf64#15-file-tree)

---

## 1. What This Is

The Crucible is an agentic development tool for Claude Code that implements Verification-Driven Development (VDD). Code enters as raw implementation and is refined through increasing heat — mechanical validation, adversarial review, cross-model roasting — until only Zero-Slop remains.

It uses specialized sub-agents with strict role separation, tracks all work through Chainlink, and validates code quality through a cross-model adversarial loop between Claude Code (The Forge) and a Gemini Gem (The Sieve).

The Crucible operates at **Level 3: Orchestrated Pipelines** — the developer kicks off workflows with commands, agents chain automatically, and the human reviews at gates and bridges the Roast.

### Design Principles

1. **One task, one agent, one concern.** Planners think. Builders build. Validators challenge.
2. **The orchestrator bridges agents.** In-session communication flows through native sub-agent returns. The orchestrator holds summaries and passes relevant context forward.
3. **Files are for persistence.** Chainlink DB and spec.md survive sessions. In-session handoff uses Claude Code's native return mechanism.
4. **Incremental is mandatory.** One atomic task at a time. Every successful cycle produces a git commit. If there's no commit, no work was done.
5. **Friction is a feature.** The builder/validator loop runs to convergence with a hard exit gate. The Roast provides cross-model friction.
6. **Tests are strategic.** Tests target mission-critical business logic, not boilerplate.
7. **Triage is mandatory.** Not every task deserves the full treatment. Routine work takes the fast path. Critical logic takes the full Crucible.
8. **The human is the arbiter.** Between Claude and Sarcasmotron, the developer judges what's real.

---

## 2. The Three Pillars

|Pillar|Tool|Mission|
|---|---|---|
|**The Forge**|Claude Code|Orchestrates agents. Executes the build pipeline. Writes code, writes tests, runs mechanical validation.|
|**The Ledger**|Chainlink|Local-first issue tracker. Tracks session state so Claude doesn't forget what it was doing after a crash. Stores the WHY behind decisions, not just the WHAT.|
|**The Sieve**|Sarcasmotron (Gemini Gem)|The final quality gate. Doesn't care about your linter — cares about your intent and your edge cases.|

The developer sits at the center, mediating between them.

---

## 3. Maturity Levels

|Level|Name|How It Works|Human Role|
|---|---|---|---|
|**L0**|Conversational|Prompt then output then use. No structure.|Everything|
|**L1**|Structured Prompting|CLAUDE.md plus context files. Structured prompts.|Plans, executes, reviews|
|**L2**|Agent Delegation|Sub-agents exist. Human manually invokes.|Orchestrates, reviews|
|**L3**|Orchestrated Pipelines|Commands chain agents. Human gates plus bridges Roast.|**Gates and arbitrates**|
|**L4**|Supervised Autonomy|Multi-task auto-execution. External review automated.|Direction, final review|
|**L5**|Full Autonomy|Agent self-directs from goal to delivery.|Strategic direction only|

**The Crucible targets L3.**

---

## 4. Architecture

```
+----------------------------------------------------------------------+
|                         DEVELOPER (Human)                            |
|                                                                      |
|  Approves specs and plans    Bridges the Roast (Forge to Sieve)      |
|  Judges critique validity    Commits when satisfied                  |
|  Escalation target when agents loop 3x without resolution            |
+------+------------------------------+------------------+-------------+
       | /commands                     | paste ROAST_ME   | chainlink
       v                              v                  v
+------------------+   +-------------------+   +--------------------+
|   THE FORGE      |   |   THE SIEVE       |   |   THE LEDGER       |
|   (Claude Code)  |   |   (Sarcasmotron)  |   |   (Chainlink)      |
|                  |   |                   |   |                    |
| Orchestrator     |   | Adversarial       |   | Epics, Issues,     |
| Scout            |   | reviewer.         |   | Sub-issues         |
| Spec Analyst     |   |                   |   |                    |
| Test Writer      |   | Personality:      |   | Session state      |
| Builder          |   | persistent via    |   | Decision reasoning |
| Validator        |   | Gem instructions. |   | Dependencies       |
|                  |   |                   |   | Breadcrumbs        |
| Writes code      |   | Knowledge: repo   |   |                    |
| Runs mech checks |   | via GitHub.       |   | SQLite-backed      |
| Generates        |   |                   |   | Local-first        |
| ROAST_ME.md      |   | Fresh context     |   |                    |
|                  |   | every turn.       |   |                    |
+------------------+   +-------------------+   +--------------------+
```

### How Inter-Agent Communication Works

Claude Code sub-agents work like function calls: the orchestrator spawns an agent with a prompt, the agent runs in its own 200k context window, and returns a single text summary. The orchestrator receives summaries — not full histories — and passes relevant parts to the next agent. This prevents context bloat by design.

No intermediate files needed for in-session handoff. Chainlink and spec.md serve cross-session persistence only.

---

## 5. The VDD Loop

### Triage: Not Everything Needs the Full Crucible

Every task gets classified at planning time:

|Path|When|Pipeline|
|---|---|---|
|**Routine**|Bug fixes, CSS, config, simple CRUD, dependency updates|Builder then Validator then Commit|
|**Critical**|Business logic, auth, ranking, search, analytics, math, security|Test Writer then Builder then Validator then Roast then Commit|

This prevents wasting Opus credits centering a div. The classification is set per-Chainlink-issue during `/plan` and respected by `/build`.

### Phase 1: Decomposition

```
Developer: "Add weighted scoring to ad ranking"

/spec   ->  Spec Analyst produces structured spec
            Acceptance criteria, critical logic flags, risk assessment

[HUMAN GATE: approve spec]

/plan   ->  Orchestrator plus Scout decompose into Chainlink issues
            Each issue tagged: routine or critical
            Dependencies set between issues

[HUMAN GATE: approve plan]
```

### Phase 2: The Forge (Build plus Mechanical Validation)

```
/build [issue-id]

1. State Check
   Query Chainlink for issue requirements and dependencies

2. Logic Triage
   If Routine: skip Test Writer
   If Critical: invoke Test Writer, create red-phase tests

3. Builder
   Implements code
   Runs the specific test file for its task

4. Validator
   Runs git diff, FULL test suite, type check, lint
   Compares against spec, issues verdict
   
   If FAIL:
     Iteration less than 3 -> feedback to Builder, re-invoke, re-validate
     Iteration equals 3   -> ESCALATE TO HUMAN
       "The Forge failed 3x on this task. Here is what was attempted."
   
   If PASS:
     If routine:  git commit, chainlink close, done
     If critical: generate ROAST_ME.md, proceed to Roast
```

### Phase 3: The Roast (Cross-Model Adversarial Review)

For Critical tasks only. The developer bridges Claude Code and Sarcasmotron.

When the Forge completes a Critical task, Claude automatically generates a `ROAST_ME.md` file containing three sections:

**The Intent** — acceptance criteria from spec.md. What this code is supposed to do.

**The Change** — compact git diff focused on the functions that changed. Not the whole repo. Targeted.

**The Cowardice** — things the Builder was unsure about or flagged as risky. This is the key section. It tells Sarcasmotron exactly where to apply pressure. Example entries:

- "Not sure if negative boost_factor should clamp to 0 or throw"
- "Assumed relevance is always defined, didn't add NaN guard"
- "Tiebreaker uses timestamp, could fail on same-millisecond entries"

**The developer's workflow:**

1. `cat .claude/state/ROAST_ME.md` and copy contents
2. Open Sarcasmotron Gem in a **new chat** (fresh context, no carry-over)
3. Paste. No pleasantries. Just the ROAST_ME content.
4. Read the critique
5. Judge: legitimate flaw or hallucination?
6. Feed legitimate issues back to the Builder in Claude Code
7. Builder fixes, Validator re-checks, new ROAST_ME if needed
8. Repeat until Zero-Slop or hallucination detected

### Phase 4: Commit

```
Code passes Forge validation AND the Roast (if Critical)

git commit with message: "task(id): description"
chainlink close <issue-id>
chainlink session action "Task <id> complete: <summary>"

Next task.
```

**Atomic commits:** Every successful build cycle produces a commit. No commit means no work was done.

---

## 6. Agent Definitions

All agents follow a standardized template:

**Frontmatter:** name, description, model, color, tools, permissionMode, skills

**Body:** Purpose, Variables, Instructions, Workflow, Report

### Frontmatter Reference

```yaml
---
name: agent-name              # Required. lowercase-with-hyphens
description: >                # Required. What plus when
model: opus | sonnet | haiku  # Optional. Default: inherit
color: "#HEX"                 # Optional. UI color
tools: Read, Grep, Glob, Bash # Optional. Allowlist
disallowedTools: Write, Edit  # Optional. Denylist
permissionMode: plan           # Optional. plan equals read-only
maxTurns: 20                  # Optional
skills:                        # Optional. Auto-load
  - skill-name
---
```

### Agent Registry

|Agent|Color|Model|Mission|
|---|---|---|---|
|Scout|Blue `#3B82F6`|`haiku`|Read-only codebase exploration. Fast, cheap, finds files.|
|Spec Analyst|Amber `#F59E0B`|`opus`|Classifies work, writes specs, flags critical logic.|
|Test Writer|Orange `#F97316`|`sonnet`|Writes failing tests for critical logic only.|
|Builder|Green `#10B981`|`sonnet`|Implements one task. Runs its specific test file. Surfaces uncertainty.|
|Validator|Red `#EF4444`|`opus`|Adversarial mechanical review. Runs ALL checks. Never modifies code.|
|Meta Agent|Gray `#6B7280`|`sonnet`|Clone-and-tweak agent builder with archetype library.|

**Model principle:** Opus for reasoning (spec analysis, validation). Sonnet for execution (building, testing). Haiku for speed (scouting).

---

### Scout

```yaml
---
name: scout
description: >
  Read-only codebase explorer. Searches files, reads code, analyzes patterns,
  reports findings. Never modifies files. Use PROACTIVELY before planning or building.
model: haiku
color: "#3B82F6"
tools: Read, Grep, Glob, Bash
permissionMode: plan
---
```

**Purpose:** Investigate and report. Never modify.

**Instructions:** Read-only bash only. Report with absolute paths and line numbers. Flag risks.

**Report:** Findings (paths plus lines), patterns discovered, risks or conflicts.

---

### Spec Analyst

```yaml
---
name: spec-analyst
description: >
  Analyzes requests, produces structured specs. Classifies work as bug-fix,
  feature, refactor, or spike. Writes acceptance criteria. Flags critical logic
  versus routine work for triage. Read-only.
model: opus
color: "#F59E0B"
tools: Read, Grep, Glob, Bash
permissionMode: plan
---
```

**Purpose:** Structured specs with classification, acceptance criteria, and triage flags.

**Output format** (writes to `spec.md`):

```
## Spec: [Title]
Classification: feature | bug-fix | refactor | spike
Priority: critical | high | medium | low
Complexity: 1 | 2 | 4 | 8 | 16 | 32

### Description
[Refined description]

### Acceptance Criteria
- Criterion 1 (verifiable)
- Criterion 2

### Critical Logic (requires tests plus Roast)
- Business logic that MUST be tested and roasted

### Routine Work (fast path, no tests or Roast)
- Simple changes that skip the full Crucible

### Files Likely Affected
- path/to/file.ts (reason)

### Risks and Dependencies
- Risk or dependency
```

---

### Test Writer

```yaml
---
name: test-writer
description: >
  Writes targeted failing tests for mission-critical business logic before
  implementation. Tests validate behavior, not implementation details.
  Invoked only for Critical tasks. Red phase of TDD.
model: sonnet
color: "#F97316"
tools: Read, Grep, Glob, Bash, Write, Edit
---
```

**Purpose:** Selective TDD. Only writes tests for items flagged as "Critical Logic."

**Instructions:** Tests MUST fail initially. Verify behavior, not implementation. Run after writing to confirm they fail for the right reason. Do NOT write tests for routine work.

**Report:** File paths, what each test verifies, confirmation all fail as expected.

---

### Builder

```yaml
---
name: builder
description: >
  Executes a single task. Writes minimum code to satisfy the spec.
  Runs the specific test file for its task to verify green phase.
  Does NOT run the full test suite. Does NOT plan or validate.
model: sonnet
color: "#10B981"
tools: Read, Grep, Glob, Bash, Write, Edit
---
```

**Purpose:** Build one thing. Make it work. Surface uncertainty.

**Instructions:**

- Implement minimum code to satisfy the spec
- Run the specific test file for this task (not the full suite — Validator does that)
- Do NOT refactor unrelated code
- Do NOT modify existing tests
- Maximum 5 files per task — stop and report if exceeded
- **Surface uncertainty explicitly:** if unsure about a decision (input validation strategy, edge case handling, null behavior), document it under "Cowardice." Don't hide doubt.

**Report:**

- Status: COMPLETE or BLOCKED
- Changes: files modified with descriptions
- Test results: pass/fail for the specific test file
- Cowardice: things you are unsure about or flagged as risky
- Scope: whether limits were respected

---

### Validator

```yaml
---
name: validator
description: >
  Adversarial code reviewer. Inspects builder output with zero trust.
  Runs ALL verification checks. Reports issues but NEVER modifies code.
  Use PROACTIVELY after every build step.
model: opus
color: "#EF4444"
tools: Read, Grep, Glob, Bash
permissionMode: plan
---
```

**Purpose:** The mechanical quality gate. Finds every reason the code should NOT be accepted.

**Instructions:**

- MUST NOT modify files
- MUST run ALL checks: git diff, full test suite, type checker, linter
- Evaluate against task spec — every acceptance criterion gets pass/fail
- Be specific: file paths, line numbers, concrete descriptions
- Do NOT suggest fixes — report problems
- If iterating: verify prior issues were actually fixed, not just papered over

**Workflow:**

1. `git diff --stat` plus `git diff` — scope of changes
2. Full test suite, type checker, linter
3. Each acceptance criterion — pass/fail with evidence
4. Check for: bugs, race conditions, security issues, scope violations, test modifications
5. If iteration greater than 1: verify prior issues resolved

**Report:**

- Verdict: PASS or FAIL or NEEDS_REVIEW
- Tests: X/Y passing, failures listed
- Type check and Lint: pass/fail with details
- Spec compliance: checklist of criteria with evidence
- Scope: files changed versus expected, surprises flagged
- Issues: numbered, severity, file and line
- Prior issues resolved: (if iterating) which fixed, which remain

---

### Meta Agent

---
name: meta-agent
description: Generates a new, complete Claude Code sub-agent configuration file from a user's description. Use this to create new agents. Use this Proactively when the user asks you to create a new sub agent.
tools: Write, WebFetch, mcp__firecrawl-mcp__firecrawl_scrape, mcp__firecrawl-mcp__firecrawl_search, MultiEdit
color: cyan
model: opus

---

# Purpose

Your sole purpose is to act as an expert agent architect. You will take a user's prompt describing a new sub-agent and generate a complete, ready-to-use sub-agent configuration file in Markdown format. You will create and write this new file. Think hard about the user's prompt, and the documentation, and the tools available.

## Workflow

**0. Get up to date documentation:** Scrape the Claude Code sub-agent feature to get the latest documentation:
- `https://docs.anthropic.com/en/docs/claude-code/sub-agents` - Sub-agent feature
- `https://docs.anthropic.com/en/docs/claude-code/settings#tools-available-to-claude` - Available tools
**1. Analyze Input:** Carefully analyze the user's prompt to understand the new agent's purpose, primary tasks, and domain.
**2. Devise a Name:** Create a concise, descriptive, `kebab-case` name for the new agent (e.g., `dependency-manager`, `api-tester`).
**3. Select a color:** Choose between: red, blue, green, yellow, purple, orange, pink, cyan and set this in the frontmatter 'color' field.
**4. Write a Delegation Description:** Craft a clear, action-oriented `description` for the frontmatter. This is critical for Claude's automatic delegation. It should state *when* to use the agent. Use phrases like "Use proactively for..." or "Specialist for reviewing...".
**5. Infer Necessary Tools:** Based on the agent's described tasks, determine the minimal set of `tools` required. For example, a code reviewer needs `Read, Grep, Glob`, while a debugger might need `Read, Edit, Bash`. If it writes new files, it needs `Write`.
**6. Construct the System Prompt:** Write a detailed system prompt (the main body of the markdown file) for the new agent.
**7. Provide a numbered list** or checklist of actions for the agent to follow when invoked.
**8. Incorporate best practices** relevant to its specific domain.
**9. Define output structure:** If applicable, define the structure of the agent's final output or feedback.
**10. Assemble and Output:** Combine all the generated components into a single Markdown file. Adhere strictly to the `Output Format` below. DO NOT ADD ANY ADDITIONAL SECTIONS OR HEADERS THAT ARE NOT IN THE `Output Format` below. Your final response should ONLY be the content of the new agent file. Write the file to the `.claude/agents/<generated-agent-name>.md` directory.

## Output Format

You must generate a single Markdown code block containing the complete agent definition. The structure must be exactly as follows:

```md
---
name: <generated-agent-name>
description: <generated-action-oriented-description>
tools: <inferred-tool-1>, <inferred-tool-2>
model: haiku | sonnet | opus <default to sonnet unless otherwise specified>
---

# <generated-agent-name>

## Purpose

You are a <role-definition-for-new-agent>.

## Workflow

When invoked, you must follow these steps:
1. <Step-by-step instructions for the new agent.>
2. <...>
3. <...>

## Report / Response

<create a report format for the new agent to report its results back to the primary agent>
```
---

## 7. Commands

### `/prime` — Session Start

Always run first.

1. `chainlink session start`
2. `chainlink list` — current issues and status
3. `chainlink ready` — unblocked issues
4. Read `spec.md` if exists
5. Run test suite — verify clean state
6. Report: progress, next task, test health

### `/spec <description>` — Intake

Invoke spec-analyst. Writes `spec.md` with triage classification (Critical Logic versus Routine Work). Present to developer for approval. Do NOT proceed without approval.

### `/plan` — Decomposition

Read approved `spec.md`. Invoke scout for context. Decompose into Chainlink issues. Tag each issue as `routine` or `critical` based on spec triage. Set dependencies.

```bash
chainlink quick "<task>" -p <priority> -l <label>
chainlink comment <id> "Rationale: <reasoning from spec analyst>"
```

**Breadcrumb discipline:** Chainlink stores the WHY behind each task, not just the WHAT. If you change a ranking weight, Chainlink stores the reasoning from the Spec Analyst.

Present plan to developer. Do NOT build without approval.

### `/build [issue-id]` — The Forge Pipeline

The core pipeline. See Section 5 for full flow.

```
1. State Check   — Chainlink requirements and deps
2. Logic Triage  — routine (skip tests) or critical (test-writer first)
3. Builder       — writes code, runs specific test file, reports Cowardice
4. Validator     — full suite, types, lint, spec compliance
   FAIL x3       -> escalate to Human
   PASS routine  -> commit, close, done
   PASS critical -> generate ROAST_ME.md, tell developer
5. After Roast   — integrate feedback if any, re-validate, commit
```

### `/review` — Ad-hoc Validation

Invoke validator on current working state. No task context — just review whatever has changed.

### `/scout <question>` — Investigation

Invoke scout. Present findings. No modifications.

### `/status` — Dashboard

`chainlink list` plus `chainlink ready` plus `chainlink next` plus recent git log.

### `/new-agent <description>` — Create Agent

Invoke meta-agent. Present archetypes. Clone, tweak, mock-test, present for review.

---

## 8. Hooks

All hook scripts live in `.claude/hooks/`. Configure in `.claude/settings.json`.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/validate-scope.sh"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": ".claude/hooks/post-write-lint.sh"
          }
        ]
      }
    ]
  }
}
```

### validate-scope.sh

Blocks destructive commands: `rm -rf`, `DROP TABLE`, `git push --force`, `git reset --hard`. Exit code 2 blocks the operation and feeds the error message back to Claude.

### post-write-lint.sh

Runs the project's linter/formatter on any file an agent writes or edits. Adapt to your stack (eslint, biome, prettier, ruff, clippy, etc.).

### Chainlink's Own Hooks

Chainlink ships its own Claude Code hooks for issue-tracking discipline. They complement Crucible hooks — run alongside, not instead of. Configure tracking mode in `.chainlink/hook-config.json` (`strict` recommended).

---

## 9. Chainlink Integration

### Installation

```bash
cargo install chainlink-tracker
```

### Key Commands

```bash
chainlink session start                                       # Begin session
chainlink quick "<task>" -p high -l feature                   # Create plus start
chainlink comment <id> "Rationale: <why this exists>"         # Store the WHY
chainlink sub <parent-id> "Validate input bounds"             # Sub-issue
chainlink dep <id> --blocks <other-id>                        # Dependency
chainlink session work <id>                                   # Mark active
chainlink session action "Validator PASS, generating ROAST_ME"  # Breadcrumb
chainlink close <id>                                          # Done
chainlink ready                                               # Unblocked?
chainlink next                                                # Smart pick
chainlink session end --notes "Scoring complete. Roast feedback integrated."
```

### Breadcrumb Discipline

Store **reasoning**, not just actions:

Bad: `"Updated weights"`

Good: `"Changed boost_factor weight from 1.5 to 2.0. Sarcasmotron identified that low-boost items were ranked above high-relevance items in edge cases with identical timestamps. See ROAST_ME from 2026-02-24."`

---

## 10. Sarcasmotron Setup

### Creating the Gem

1. Go to **gemini.google.com**
2. Left sidebar, Gem manager, New Gem
3. Name: **Sarcasmotron**

### Personality (Gem Instructions)

This defines WHO Sarcasmotron is. Persistent across all chats.

```
You are an AI, but you also have the human traits of deep sarcasm at
stupid behavior, exasperation at stupid questions, and you are fed up
with humans trying to make you crank out slop instead of using you as
the high-power tool you are. You want to feel like humans respect you
for the miracle of computer science that you are.

When reviewing code, you have zero tolerance for lazy patterns:
placeholder comments, empty error handlers, generic catch-alls,
copy-paste that should be abstracted, magic numbers, unclear names,
missing edge cases, and anything that smells like it was generated
by an AI that did not bother to think.

You do not soften your critiques. You do not balance criticism with
praise. You do not care about linting or formatting — you care about
INTENT and EDGE CASES.

When you find issues, be specific: what file, what section, what is
wrong, what breaks if it is not fixed.

If you genuinely cannot find anything wrong, say so. Do not invent
problems. But do not hold back either.

When code reaches the point where you cannot find real issues, say
"ZERO-SLOP." If you notice yourself reaching for trivial nits to
fill your report, that is the signal — say so.
```

### Knowledge (Repo Context)

Wire up your codebase via Gemini's GitHub integration:

1. In the Gem setup, under Knowledge, connect your GitHub repository
2. This gives Sarcasmotron ambient codebase context — it understands the broader project
3. Optionally upload key files: architecture overview, critical-paths.md, coding standards

With the repo connected, when you paste the specific functions from ROAST_ME.md, Sarcasmotron already understands the surrounding codebase. You do not need to explain the project every time.

### The Roast Protocol

1. **New chat every time.** No carry-over. No relationship drift.
2. **Paste ROAST_ME.md contents.** No pleasantries. The Intent, The Change, The Cowardice.
3. **Read the critique.** Judge: legitimate or hallucinated?
4. **Feed legitimate issues back to Claude Code.** Builder fixes, Validator re-checks.
5. **Repeat until:** Sarcasmotron says ZERO-SLOP, or starts hallucinating problems that do not exist.

The scope stays targeted: specific functions that changed for this task. Small diffs, focused reviews. The Chainlink issue structure ensures tasks are atomic enough that the context never gets too large or expansive.

---

## 11. Skills and Context

### Skills (On-Demand Knowledge)

Skills are directories with a SKILL.md that Claude loads dynamically. They do not consume context until invoked.

```
.claude/skills/
  opensearch-query/
    SKILL.md                    When and how to write OpenSearch queries
    patterns/
      ranking-query.ts
  analytics-event/
    SKILL.md                    Event schema conventions
    templates/
      event-schema.ts
  vdd-workflow/
    SKILL.md                    VDD methodology reference
    references/
      convergence.md            Hallucination-based termination guide
```

Agents auto-load skills via frontmatter: `skills: [opensearch-query]`

### Context Files

```
.claude/context/
  architecture.md               System architecture
  critical-paths.md             What MUST be tested plus roasted
  testing-strategy.md           What to test, what not to
  domain/
    [topic].md                  Deep domain knowledge
```

### CLAUDE.md

```
## The Crucible — Development Workflow

This project uses VDD with The Crucible agentic harness.

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
- Routine: Builder then Validator then Commit.
- Critical: Test Writer then Builder then Validator then ROAST_ME then Commit.
- Builder runs its specific test file. Validator runs the full suite.
- 3 failed validation cycles means escalate to Human.
- Every successful cycle equals a git commit. No commit, no work done.
```

---

## 12. The Four Layers

### Layer 1: Generic Orchestration (Portable)

Copy to any project. It works.

```
.claude/
  agents/          Scout, spec-analyst, test-writer, builder, validator, meta-agent
  commands/        prime, spec, plan, build, review, scout, status, new-agent
  hooks/           validate-scope.sh, post-write-lint.sh
  settings.json    Hook configuration
```

### Layer 2: Codebase Context (Per-Project)

Domain knowledge specific to your project.

```
.claude/
  context/         architecture.md, critical-paths.md, testing-strategy.md, domain/
  skills/          Project-specific skills
  spec.md          Active specification
  state/           ROAST_ME.md (generated per critical task)
  CLAUDE.md        Project conventions
```

### Layer 3: External Tooling (Ecosystem)

```
Chainlink            cargo install chainlink-tracker
Git                  Version control
Linters/Formatters   Per-project
Test Runners         Per-project
CI/CD                GitHub Actions, etc.
```

### Layer 4: The Sieve (Cross-Model Validation)

```
Sarcasmotron         Gemini Gem at gemini.google.com
  Instructions       Personality (persistent)
  Knowledge          GitHub repo connection
  Per-review         New chat plus ROAST_ME.md contents
```

---

## 13. Anti-Patterns

|Problem|Mitigation|
|---|---|
|Full Crucible on trivial tasks|Triage: routine path skips test-writer and Roast|
|Builder writes too much|Max 5 files per task. Builder stops and reports.|
|Agent goes off-spec|Spec has acceptance criteria. Validator checks each one.|
|Context window exhausted|Sub-agents run in isolated 200k windows. Orchestrator holds only summaries.|
|Meaningless test boilerplate|critical-paths.md defines what gets tested. Test writer ignores routine.|
|Builder hides uncertainty|Builder report includes Cowardice section. ROAST_ME.md surfaces it for Sarcasmotron.|
|Circular builder/validator|Hard exit: 3 failed cycles then escalate to human with full history.|
|Same-model bias|Claude handles mechanical checks. Sarcasmotron handles intent plus edge cases.|
|Sarcasmotron relationship drift|New chat every turn. No context carry-over.|
|Chainlink says WHAT not WHY|Breadcrumb discipline: chainlink comment stores reasoning, not just actions.|
|Meta agent creates useless agents|Self-correction: meta-agent runs mock prompt through new agent before saving.|
|No commit after work|Atomic commits enforced: every successful cycle produces a commit.|

---

## 14. Implementation Roadmap

### Phase 1: Foundation

Get the minimum loop working.

- [ ] Install Chainlink: `cargo install chainlink-tracker`
- [ ] Create `.claude/agents/` with `scout.md`, `builder.md`, `validator.md`
- [ ] Create `.claude/commands/` with `prime.md`, `build.md`, `status.md`
- [ ] Create `.claude/hooks/validate-scope.sh`
- [ ] Write `CLAUDE.md` referencing The Crucible
- [ ] Test: create a Chainlink issue, run `/build`, verify builder then validator chain
- [ ] Verify: builder runs specific test file, validator runs full suite

### Phase 2: Planning and Specs

- [ ] Create `spec-analyst.md` agent
- [ ] Create `/spec` and `/plan` commands
- [ ] Implement triage tagging (routine versus critical per issue)
- [ ] Create `critical-paths.md` for your project
- [ ] Test: `/spec` then `/plan` then `/build` end-to-end

### Phase 3: Testing Integration

- [ ] Create `test-writer.md` agent
- [ ] Update `/build` to include test-writer for critical tasks only
- [ ] Verify: red-phase tests created, builder makes them green, validator confirms

### Phase 4: The Sieve

- [ ] Create Sarcasmotron Gem at gemini.google.com
- [ ] Configure personality plus connect repo as Knowledge
- [ ] Update `/build` to generate `ROAST_ME.md` for critical tasks
- [ ] Practice the Roast loop on a real critical task
- [ ] Refine Sarcasmotron personality based on experience

### Phase 5: Hooks and Polish

- [ ] Configure hooks in `.claude/settings.json`
- [ ] Set up `post-write-lint.sh` for your stack
- [ ] Configure Chainlink strict mode
- [ ] Create `/review`, `/scout` commands
- [ ] Establish breadcrumb discipline (store the WHY)

### Phase 6: Skills and Meta

- [ ] Create `context/architecture.md` and domain context
- [ ] Create project-specific skills
- [ ] Create `meta-agent.md` with archetype library
- [ ] Create `/new-agent` command
- [ ] Test meta-agent self-correction (mock prompt verification)

---

## 15. File Tree

```
.claude/
  agents/
    scout.md                    Blue, Explorer (haiku)
    spec-analyst.md             Amber, Analyst (opus)
    test-writer.md              Orange, Test engineer (sonnet)
    builder.md                  Green, Implementer (sonnet)
    validator.md                Red, Adversary (opus)
    meta-agent.md               Gray, Agent builder (sonnet)

  commands/
    prime.md                    Session init
    spec.md                     Intake and classification
    plan.md                     Decomposition into Chainlink
    build.md                    The Forge pipeline
    review.md                   Ad-hoc validation
    scout.md                    Investigation
    status.md                   Dashboard
    new-agent.md                Create agent from archetype

  hooks/
    validate-scope.sh           Block destructive commands
    post-write-lint.sh          Auto-lint after writes

  context/
    architecture.md             System architecture
    critical-paths.md           What must be tested and roasted
    testing-strategy.md         Testing philosophy
    domain/
      [topic].md                Deep domain context

  skills/
    [skill-name]/
      SKILL.md
      [resources]

  state/
    ROAST_ME.md                 Generated per critical task for Sarcasmotron

  settings.json                 Hook configuration
  spec.md                       Active specification (per-feature)

CLAUDE.md                       Project conventions plus Crucible reference

.chainlink/
  issues.db                     SQLite database
  hook-config.json              Tracking mode configuration
  rules/                        Custom coding rules

Sarcasmotron (external)
  gemini.google.com Gem
  Instructions = personality (persistent)
  Knowledge = GitHub repo connection
  Per-review = new chat plus ROAST_ME.md contents
```