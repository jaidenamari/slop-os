#!/usr/bin/env bash
# post-write-lint.sh — Runs shellcheck on .sh/.bash files after Write/Edit.
# This is a PostToolUse advisory hook. It always exits 0.
# Output: JSON with hookSpecificOutput for Claude Code hook protocol.
#
# The existing post-edit-check.py handles Python, JS/TS, Rust, and Go linting.
# This hook fills the gap: shell script linting via shellcheck.

set -uo pipefail

# --- Helper: emit hook JSON output and exit 0 ---
emit_result() {
    local msg="$1"
    python3 -c "
import json, sys
msg = sys.argv[1]
output = {
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': msg
    }
}
print(json.dumps(output))
" "$msg" 2>/dev/null
    exit 0
}

# --- Read hook input JSON from stdin ---
INPUT=$(cat 2>/dev/null) || INPUT=""

if [ -z "$INPUT" ]; then
    exit 0
fi

# --- Extract file_path from tool_input (same pattern as validate-scope.sh) ---
FILE_PATH=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    data = json.load(sys.stdin)
    ti = data.get('tool_input', {})
    print(ti.get('file_path', ''))
except:
    print('')
" 2>/dev/null)

if [ -z "$FILE_PATH" ]; then
    exit 0
fi

# --- Only process .sh and .bash files ---
case "$FILE_PATH" in
    *.sh|*.bash) ;;
    *)
        exit 0
        ;;
esac

# --- Skip files inside .claude/hooks/ to avoid recursive linting ---
case "$FILE_PATH" in
    */.claude/hooks/*)
        exit 0
        ;;
esac

# --- Check that the file actually exists and is readable ---
if [ ! -r "$FILE_PATH" ]; then
    exit 0
fi

BASENAME=$(basename "$FILE_PATH")

# --- Check if shellcheck is available ---
if ! command -v shellcheck &>/dev/null; then
    emit_result "shellcheck not installed -- skipping shell lint for ${BASENAME}. Install with: brew install shellcheck"
fi

# --- Run shellcheck (JSON output, with timeout for safety) ---
# timeout may not exist on all systems; fall back to running without it
if command -v timeout &>/dev/null; then
    SC_OUTPUT=$(timeout 4 shellcheck -f json "$FILE_PATH" 2>/dev/null) || true
else
    SC_OUTPUT=$(shellcheck -f json "$FILE_PATH" 2>/dev/null) || true
fi

# --- If shellcheck produced no output or empty array, report clean ---
if [ -z "$SC_OUTPUT" ] || [ "$SC_OUTPUT" = "[]" ]; then
    emit_result "shellcheck: ${BASENAME} -- no issues found"
fi

# --- Parse shellcheck JSON and format findings via python3 (piped for safety) ---
echo "$SC_OUTPUT" | python3 -c "
import json, sys, os

basename = sys.argv[1]
raw = sys.stdin.read()

try:
    findings = json.loads(raw)
except Exception:
    findings = []

if not findings:
    msg = 'shellcheck: ' + basename + ' -- no issues found'
else:
    lines = []
    shown = 0
    for f in findings:
        if shown >= 10:
            lines.append(f'  ... and {len(findings) - 10} more issues')
            break
        level = f.get('level', 'info')
        code = f.get('code', '?')
        ln = f.get('line', '?')
        message = f.get('message', '')
        lines.append(f'  L{ln} [{level}] SC{code}: {message}')
        shown += 1

    msg = f'shellcheck found {len(findings)} issue(s) in {basename}:' + chr(10) + chr(10).join(lines)

output = {
    'hookSpecificOutput': {
        'hookEventName': 'PostToolUse',
        'additionalContext': msg
    }
}
print(json.dumps(output))
" "$BASENAME" 2>/dev/null

exit 0
