---
name: new-agent
description: Create a new sub-agent. Invokes the meta-agent to generate a complete agent configuration file from a description.
argument-hint: "<description of the agent to create>"
---

# Create Agent — /new-agent $ARGUMENTS

You are creating a new sub-agent for this project. The meta-agent will architect and generate the agent file.

## Step 1: Validate Input

If `$ARGUMENTS` is empty, ask the developer to describe the agent they want. Prompt with:

> What agent do you want to create? Describe its purpose, what it should do, and any constraints.
> Examples:
> - "A migration planner that analyzes database schema changes and generates migration scripts"
> - "A documentation reviewer that checks docs for accuracy against the codebase"
> - "A performance profiler that identifies slow code paths and suggests optimizations"

Do not proceed without a description.

## Step 2: Create Chainlink Issue

Before any work begins, track the agent creation:

```bash
chainlink quick "Create $ARGUMENTS agent" -p medium -l agent
chainlink session work <new-issue-id>
```

## Step 3: Invoke Meta-Agent

Launch the **meta-agent** with:

> Create a new Claude Code sub-agent based on the following description:
>
> **Description:** $ARGUMENTS
>
> Follow your full workflow: fetch current documentation, read existing agents for patterns, analyze the request, then generate and write the complete agent file to `.claude/agents/`.
>
> Important constraints:
> - Match the structure and style of existing agents in `.claude/agents/`
> - Choose the minimal toolset needed
> - Do not create an agent that duplicates an existing one
> - The agent must be immediately usable after creation

The meta-agent will generate the file and return its report.

## Step 4: Present for Review

Show the developer the meta-agent's report, then read and display the generated agent file:

1. **Agent summary:** Name, model, color, tools, purpose
2. **Full file contents:** Display the generated `.claude/agents/<name>.md`
3. **Design rationale:** Why these choices were made
4. **Duplicate check:** Confirmation no existing agent overlaps

Ask the developer to review:

> Agent file created at `.claude/agents/<name>.md`. Review the configuration above. Should I keep it as-is, make adjustments, or discard it?

## Step 5: Log the Creation

```bash
chainlink session action "New agent created: <name> — <brief description of purpose and model>"
chainlink close <issue-id>
```
