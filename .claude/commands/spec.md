---
name: spec
description: Intake and classification. Invokes the spec-analyst agent to produce a structured spec with triage classification, then writes spec.md for developer approval.
argument-hint: "<description of what to build>"
---

# Spec Intake — /spec $ARGUMENTS

You are running the intake phase of the Crucible pipeline. Your job is to invoke the spec-analyst agent with the developer's description, write the resulting spec to `spec.md`, and present it for approval.

## Step 1: Validate Input

If `$ARGUMENTS` is empty, ask the developer what they want to build. Do not proceed without a description.

## Step 2: Invoke Spec Analyst

Launch the **spec-analyst** agent (subagent_type: "Plan") with this prompt:

> Analyze the following request and produce a structured spec following your output format.
>
> **Developer's request:** $ARGUMENTS
>
> Investigate the codebase first. Ground your spec in what actually exists. Classify as feature, bug-fix, refactor, or spike. Separate Critical Logic from Routine Work. Every acceptance criterion must be independently verifiable.

The spec-analyst is read-only and uses model opus. It will return the full spec content and a report.

## Step 3: Write spec.md

Take the spec content from the spec-analyst's output and write it to `spec.md` in the project root.

```bash
chainlink session action "Spec written: spec.md — [title from spec]"
```

## Step 4: Present for Approval

Show the developer:
1. The **classification** (feature/bug-fix/refactor/spike)
2. The **triage summary** (N critical items, N routine items)
3. The **acceptance criteria** list
4. Any **ambiguities flagged** that need developer input

Then ask: **"Approve this spec? If changes are needed, describe them and I'll revise."**

Do NOT proceed to `/plan` without explicit developer approval. The spec is a gate.

## Step 5: Log Completion

```bash
chainlink session action "Spec APPROVED for: [title]"
```

If the developer requests revisions:

```bash
chainlink session action "Spec REVISION requested: [reason for revision]"
```

Re-invoke the spec-analyst with the updated requirements and repeat from Step 3.
