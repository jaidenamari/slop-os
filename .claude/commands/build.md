---
name: build
description: The Forge pipeline. Builds a single Chainlink issue through the full builder->validator loop with triage-aware routing.
argument-hint: "[issue-id]"
---

# The Forge — /build $ARGUMENTS

You are executing the Forge pipeline for a single task. Follow this pipeline exactly.

## Step 1: State Check

Query Chainlink for the issue requirements and dependencies.

```bash
chainlink show $ARGUMENTS
```

If the issue has open blockers, STOP and report them. Do not build blocked issues.

Mark the issue as active work:
```bash
chainlink session work $ARGUMENTS
```

## Step 2: Logic Triage

Check the issue labels for triage classification:
- **routine** label → Skip to Step 3 (no test-writer)
- **critical** label → Invoke the test-writer agent first (Step 2a), THEN proceed to Step 3

If no label is set, treat as **routine** and note this in the session log.

```bash
chainlink session action "Triage: [routine|critical] for issue #$ARGUMENTS"
```

### Step 2a: Test Writer (critical path only)

Invoke the **test-writer** agent with:
- The issue requirements and acceptance criteria from the `chainlink show` output in Step 1
- The critical logic that needs test coverage (identified from the issue description and labels)
- The spec context (pass `spec.md` if it exists at `.claude/spec.md`)
- Any relevant scout findings about existing test infrastructure (test framework, conventions, file locations)

The test-writer creates red-phase tests that MUST FAIL initially. It will run the tests itself and confirm all failures are behavioral (not syntax or import errors).

**If test-writer reports BLOCKED:** Stop the pipeline. Log the blocker. Do NOT proceed to the builder.

```bash
chainlink session action "Test Writer BLOCKED for critical task #$ARGUMENTS: [blocker reason]"
```

Escalate to human with the test-writer's report.

**If test-writer reports COMPLETE:** Log the test file paths and proceed to Step 3. Pass the test files to the builder so it knows which tests to make pass.

```bash
chainlink session action "Test Writer COMPLETE for critical task #$ARGUMENTS: [test files created]"
```

Carry forward the test-writer's report (test file paths and failure confirmations) as context for the builder in Step 3.

## Step 3: Builder

Invoke the **builder** agent with:
- The issue requirements from Chainlink
- The spec context (if spec.md exists)
- The specific test file to run (if test-writer created one)
- Any relevant scout findings

The builder implements the code and runs its specific test file.

**If builder reports BLOCKED:** Stop the pipeline. Log the blocker. Escalate to human.

## Step 4: Validator

Invoke the **validator** agent to review the builder's output:
- Full test suite
- Type checker
- Linter
- Spec compliance check against acceptance criteria

### On FAIL:
- If iteration < 3: Feed validator feedback back to the builder. Re-invoke builder with the specific issues. Re-validate.
- If iteration = 3: **ESCALATE TO HUMAN.** Report all three attempts and what failed each time.

```bash
chainlink session action "Validator FAIL iteration [N]: [summary of issues]"
```

### On PASS:

**If routine:**
```bash
chainlink session action "Validator PASS for routine task #$ARGUMENTS"
chainlink close $ARGUMENTS
```
Tell the developer the task is ready to commit.

**If critical:**
Generate `.claude/state/ROAST_ME.md` with three sections:
1. **The Intent** — acceptance criteria from the spec
2. **The Change** — compact git diff focused on the functions that changed
3. **The Cowardice** — uncertainty items from the builder's report

```bash
chainlink session action "Validator PASS for critical task #$ARGUMENTS. ROAST_ME.md generated. Awaiting Roast."
```
Tell the developer to bridge the ROAST_ME.md to Sarcasmotron.

## Step 5: After Roast (if critical)

If the developer returns with Roast feedback:
- Feed legitimate issues to the builder
- Re-validate
- Generate new ROAST_ME.md if needed
- Repeat until ZERO-SLOP or developer is satisfied

```bash
chainlink close $ARGUMENTS
chainlink session action "Task #$ARGUMENTS complete: [summary]"
```
