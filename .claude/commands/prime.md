---
name: prime
description: Session initialization. Run this at the start of every session to establish context, check Chainlink state, and verify test health.
allowed-tools: Read, Grep, Glob, Bash
---

# Session Start — /prime

You are initializing a new working session. Follow these steps exactly:

## Steps

1. **Start or resume a Chainlink session.**
   ```bash
   chainlink session start
   ```
   If a session is already active, that's fine — continue with it.

2. **Check current issue state.**
   ```bash
   chainlink list
   chainlink ready
   chainlink next
   ```

3. **Read the active spec** if `spec.md` exists in the project root or `.claude/`.
   ```bash
   cat spec.md 2>/dev/null || cat .claude/spec.md 2>/dev/null || echo "No active spec."
   ```

4. **Run the test suite** to verify clean state. Use whatever test runner the project has configured. If no tests exist yet, note that.

5. **Check recent git history** for context on what was done last.
   ```bash
   git log --oneline -10
   ```

6. **Report to the developer:**
   - Session status (new or resumed)
   - Open issues count and next recommended task
   - Active spec summary (if any)
   - Test health (all passing / failures / no tests yet)
   - Any blockers or risks

Keep the report concise. The developer wants to know: **where are we, and what's next?**
