---
name: status
description: Dashboard view. Shows Chainlink state, ready issues, and recent git activity.
allowed-tools: Bash, Read
---

# Status Dashboard — /status

Show the developer a concise overview of the project state.

## Steps

1. **Chainlink overview:**
   ```bash
   chainlink list
   ```

2. **Ready to work:**
   ```bash
   chainlink ready
   ```

3. **Next recommended:**
   ```bash
   chainlink next
   ```

4. **Recent git activity:**
   ```bash
   git log --oneline -10
   ```

5. **Current session:**
   ```bash
   chainlink timer
   ```

## Report Format

Present a concise dashboard:
- **Open issues:** [count] ([count] ready, [count] blocked)
- **Next task:** #[id] — [title]
- **Current timer:** [issue and elapsed time, or "none"]
- **Recent commits:** [last 3-5 one-liners]

Keep it short. The developer wants a glance, not a novel.
