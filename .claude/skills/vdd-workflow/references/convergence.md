# Convergence — When to Stop Iterating

This reference defines the termination signals for each iterative loop in The Crucible. Every loop has a hard exit condition and soft convergence signals. Recognize these to avoid wasted cycles.

## Builder/Validator Loop

### Hard Exit: 3 Failures

After 3 failed validation cycles on the same issue, STOP and escalate to the human. Provide:

- What was attempted in each iteration
- What the validator flagged each time
- Whether the same issue keeps recurring or new issues surface each time
- Your assessment of why convergence isn't happening

### Convergence Signals

The loop is converging when:
- Each iteration fixes the previous validator findings
- The number of issues decreases iteration over iteration
- New issues (if any) are lower severity than prior ones

The loop is NOT converging when:
- The same issue appears in multiple iterations (fix isn't sticking)
- Fixing one issue introduces a new issue of equal or higher severity
- The builder is making changes outside the task scope to satisfy the validator
- The number of issues is stable or increasing

### Common Stall Patterns

1. **Whack-a-mole** — Fixing A breaks B, fixing B breaks A. Signal: the same two files keep changing. Resolution: the task decomposition is wrong — escalate to split the issue.

2. **Scope creep** — Validator flags issues in code the builder didn't write. Signal: git diff shows changes in files not listed in the task spec. Resolution: builder should only fix issues in its assigned files. Unrelated issues go into a new Chainlink issue.

3. **Specification gap** — Builder and validator disagree because the spec is ambiguous. Signal: validator flags "doesn't match spec" but the spec doesn't clearly define the behavior. Resolution: escalate to human for spec clarification.

## Roast Loop (Sarcasmotron)

### Termination Signals

**ZERO-SLOP** — Sarcasmotron explicitly says it cannot find real issues. This is the positive termination. The code is ready.

**Hallucination detected** — Sarcasmotron raises issues that:
- Reference code that doesn't exist in the diff
- Describe a behavior that the code demonstrably doesn't have
- Contradict the acceptance criteria without justification
- Repeat a prior critique that was already addressed

When hallucination is detected, the developer should stop the Roast loop. Continuing yields diminishing returns and risks introducing unnecessary changes.

### Healthy Roast Pattern

```
Round 1: Sarcasmotron finds 3 legitimate issues
Round 2: Issues fixed. Sarcasmotron finds 1 new edge case.
Round 3: Edge case fixed. Sarcasmotron says ZERO-SLOP.
```

### Unhealthy Roast Pattern

```
Round 1: Sarcasmotron finds 3 issues
Round 2: 2 fixed, 1 dismissed as hallucination. Sarcasmotron finds 2 new issues.
Round 3: 1 fixed, 1 is a nitpick. Sarcasmotron finds 1 more issue in unrelated code.
Round 4: Issue is in code outside the diff. Developer calls it — hallucination drift.
```

The key signal: Sarcasmotron starts reaching outside the diff to find things to criticize. That's the point of diminishing returns.

### Fresh Context Rule

Always start a new Sarcasmotron chat for each round. Context carry-over causes relationship drift — Sarcasmotron either gets softer (wants to please) or harder (wants to win) across rounds. Fresh context ensures consistent adversarial quality.

## Test Writer Loop

The test writer does not loop. It runs once per critical task:

1. Write failing tests (red phase)
2. Verify they fail for the right reason
3. Done

If the tests pass immediately, something is wrong — either the behavior already exists or the tests are not testing the right thing. Report this to the orchestrator; do not proceed to the builder.

## General Principle

**Stop when the signal-to-noise ratio drops below 1.** If the last iteration produced more noise (false positives, hallucinations, scope creep) than signal (legitimate issues fixed), the loop has converged. Ship it.
