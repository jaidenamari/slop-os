---
name: plan
description: Decomposition. Reads the approved spec.md, investigates the codebase with scout, then decomposes into Chainlink issues with triage tags (routine/critical) and dependencies.
---

# Plan Decomposition — /plan

You are decomposing an approved spec into actionable Chainlink issues. Each issue gets a triage tag (routine or critical) that determines its pipeline path in `/build`.

## Step 1: Read the Approved Spec

Read `spec.md` from the project root. If it does not exist, tell the developer to run `/spec` first.

Confirm the spec has been approved. If there is no evidence of approval (e.g., the spec was just written and not reviewed), remind the developer that `/spec` output must be approved before planning.

## Step 2: Investigate with Scout

Launch the **scout** agent to investigate the codebase for context relevant to the spec:
- Files that will be affected
- Existing patterns and conventions
- Potential conflicts or risks
- Dependencies between the planned changes

The scout is read-only and fast (haiku). Use its findings to inform how you decompose the work.

## Step 3: Decompose into Issues

Break the spec into atomic, independently buildable tasks. Each task should:
- Touch at most 5 files (the builder's hard limit)
- Have clear acceptance criteria derived from the spec
- Be tagged with a triage label based on the spec's Critical Logic vs Routine Work sections

**Triage rules:**
- Read `.claude/context/critical-paths.md` for the project's defined critical areas and decision guide
- Work listed under **Critical Logic** in the spec → label `critical`
- Work listed under **Routine Work** in the spec → label `routine`
- If unclear, consult the decision guide in `critical-paths.md`, then default to `routine` and note why

For each issue, create it in Chainlink:

```bash
chainlink quick "<task title>" -p <priority> -l <routine|critical>
chainlink comment <id> "Rationale: <reasoning from spec — WHY this task exists and WHY it has this triage level>"
```

Set dependencies between issues where order matters:

```bash
chainlink dep <id> --blocks <other-id>
```

## Step 4: Log the Plan

```bash
chainlink session action "Plan decomposed: [N] issues created ([N] routine, [N] critical) from spec [title]"
```

## Step 5: Present for Approval

Show the developer:
1. **Issue list** — each issue with its ID, title, priority, and triage tag
2. **Dependency graph** — which issues block which
3. **Suggested build order** — the sequence to execute via `/build`
4. **Triage summary** — count of routine vs critical tasks

Then ask: **"Approve this plan? If changes are needed, describe them and I'll adjust."**

Do NOT start building without explicit developer approval. The plan is a gate.

## Step 6: Log Approval

```bash
chainlink session action "Plan APPROVED: [N] issues ready for /build"
```

If the developer requests changes, adjust the Chainlink issues accordingly and re-present.

```bash
chainlink session action "Plan REVISION: [what changed and why]"
```
