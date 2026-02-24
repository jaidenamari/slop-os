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
Generate `.claude/state/ROAST_ME.md` by following these steps exactly:

1. **Gather the three sections:**
   - **The Intent:** Pull the acceptance criteria from the Chainlink issue (`chainlink show $ARGUMENTS`). If a spec.md exists, include the relevant acceptance criteria from it. This tells the reviewer what the code is *supposed* to do.
   - **The Change:** Run `git diff HEAD` (or `git diff` for unstaged changes) and extract only the functions/blocks that changed. Strip file headers, context lines, and unrelated hunks. Keep it compact — the reviewer needs to see *what changed*, not the whole repo.
   - **The Cowardice:** Extract uncertainty items from the builder's report (the "Cowardice" section). These are decisions the builder was unsure about — edge cases, assumptions, naming choices, missing validations. This tells the reviewer exactly where to apply pressure.

2. **Write the file** to `.claude/state/ROAST_ME.md` using this format:

```markdown
# ROAST_ME — Issue #[id]: [title]

## The Intent
[Acceptance criteria. What this code must do.]

## The Change
[Compact diff of changed functions/blocks. Code only, no noise.]

## The Cowardice
[Builder's uncertainty items. Where pressure should be applied.]
```

3. **Log and notify:**

```bash
chainlink session action "Validator PASS for critical task #$ARGUMENTS. ROAST_ME.md generated. Awaiting Roast."
```

Tell the developer:
- The ROAST_ME.md is ready at `.claude/state/ROAST_ME.md`
- Open a **new chat** in the Sarcasmotron Gem (fresh context every time)
- Paste the full contents of ROAST_ME.md — no pleasantries, no explanation
- Read the critique, judge which issues are legitimate vs hallucinated
- Bring legitimate issues back here for the builder to fix

## Step 5: After Roast (if critical)

The developer will return with Sarcasmotron's critique. For each issue raised:

1. **Triage the feedback.** The developer has already judged which criticisms are legitimate. Accept their judgement.
2. **Feed legitimate issues to the builder.** Re-invoke the builder with the specific issues to fix. Include the original task context plus the roast feedback.
3. **Re-validate.** Run the validator again after the builder fixes.
4. **Re-generate ROAST_ME.md** if the developer wants another roast round. Follow the same generation process from Step 4.
5. **Repeat** until the developer reports ZERO-SLOP (Sarcasmotron found no real issues) or is satisfied.

When the roast loop is complete:

```bash
chainlink session action "Roast loop complete for critical task #$ARGUMENTS: [summary of what was fixed from roast feedback]"
chainlink close $ARGUMENTS
chainlink session action "Task #$ARGUMENTS complete: [summary]"
```

Tell the developer the task is ready to commit.
