#!/usr/bin/env bash
# validate-scope.sh — Blocks destructive commands from being executed by agents.
# Exit code 2 blocks the operation and feeds the error message back to Claude.
#
# This is a Crucible safety hook. It catches commands that Chainlink's
# hook-config.json might miss or that bypass the allowed_bash_prefixes list.

set -euo pipefail

# Read the tool input from stdin (JSON with the command)
INPUT=$(cat)

# Extract the command being run
COMMAND=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    # Handle both direct command and nested tool_input formats
    cmd = data.get('command', '') or data.get('tool_input', {}).get('command', '')
    print(cmd)
except:
    print('')
" 2>/dev/null)

if [ -z "$COMMAND" ]; then
    exit 0
fi

# Destructive patterns to block
BLOCKED_PATTERNS=(
    "rm -rf"
    "rm -fr"
    "DROP TABLE"
    "DROP DATABASE"
    "TRUNCATE"
    "git push --force"
    "git push -f"
    "git reset --hard"
    "git clean -f"
    "git checkout \."
    "git restore \."
    "chmod -R 777"
    ":(){ :|:& };:"
    "mkfs"
    "dd if=/dev/zero"
    "\| bash"
    "\| sh"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
    if echo "$COMMAND" | grep -qi "$pattern"; then
        echo "BLOCKED by validate-scope.sh: Destructive command detected: '$pattern'" >&2
        echo "This command is not allowed. If you need to perform this action, ask the developer." >&2
        exit 2
    fi
done

exit 0
