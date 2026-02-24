---
name: review
description: Ad-hoc validation. Invokes the validator on the current working state without task context — just review whatever has changed.
allowed-tools: Bash, Read, Grep, Glob
---

# Ad-hoc Review — /review

You are running an ad-hoc validation pass. There is no Chainlink issue context — just review whatever has changed in the working tree.

## Step 1: Check for Changes

```bash
git diff --stat
```

Also check for untracked files:
```bash
git status --short
```

If there are **no changes and no untracked files**, tell the developer:

> Nothing to review. Working tree is clean with no staged, unstaged, or untracked changes.

Stop here. Do not invoke the validator on a clean tree.

## Step 2: Summarize Scope

Before invoking the validator, briefly note what changed:
- Which files were modified, added, or deleted
- Rough scope (number of files, nature of changes)

This gives the validator useful framing.

## Step 3: Invoke Validator

Launch the **validator** agent with:

> Run a full validation pass on the current working state. There is no specific Chainlink issue — this is an ad-hoc review of all uncommitted changes.
>
> Changes in scope:
> [paste the git diff --stat and git status --short output here]
>
> Run all available checks: test suite, type checker, linter, and general code review. Report everything you find.

The validator is read-only and will not modify any files.

## Step 4: Present Findings

Report the validator's results to the developer:
1. **Overall verdict:** PASS or FAIL
2. **Issues found:** List each issue with severity and location
3. **Recommendations:** What should be fixed before committing

## Step 5: Log the Review

```bash
chainlink session action "Ad-hoc /review: [PASS|FAIL] — [brief summary of findings]"
```
