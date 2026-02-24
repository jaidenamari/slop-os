---
name: scout
description: Investigation. Invokes the scout agent to explore the codebase and answer a question. Read-only — no modifications.
argument-hint: "<question or topic to investigate>"
---

# Investigation — /scout $ARGUMENTS

You are running an ad-hoc investigation. Invoke the scout agent to explore the codebase and answer the developer's question. No files are modified.

## Step 1: Validate Input

If `$ARGUMENTS` is empty, ask the developer what they want to investigate. Do not proceed without a question or topic.

## Step 2: Invoke Scout

Launch the **scout** agent with:

> Investigate the following question by exploring the codebase. Read files, search for patterns, analyze structure — but do not modify anything.
>
> **Question:** $ARGUMENTS
>
> Be thorough. Report what you find with specific file paths, line numbers, and code references. If the answer is ambiguous or the codebase doesn't have enough information, say so explicitly.

The scout is read-only and uses model haiku. It will search the codebase and return its findings.

## Step 3: Present Findings

Report the scout's findings directly to the developer:
1. **Answer:** Direct response to the question
2. **Evidence:** File paths, code snippets, and references that support the answer
3. **Gaps:** Anything the scout could not determine or flagged as uncertain

Keep the presentation clean. The developer asked a question — answer it.

## Step 4: Log the Investigation

```bash
chainlink session action "Scout investigation: $ARGUMENTS — [brief summary of findings]"
```
