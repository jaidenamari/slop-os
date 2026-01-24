#!/bin/bash
# Review on Complete Hook
# Triggers contextual code review when an agent completes work
#
# This hook fires on the `stop` event (agent session completion).
# It determines if source code was changed and triggers the review agent
# with full context: the spec, changed files, and project patterns.
#
# Input: JSON payload from Cursor hook system
# {
#   "event": "stop",
#   "sessionId": "abc123",
#   "prompt": "original user prompt",
#   "filesModified": ["path/to/file1.ts", ...]
# }

set -e

# Read hook payload from stdin
PAYLOAD=$(cat)

# Parse payload
SESSION_ID=$(echo "$PAYLOAD" | jq -r '.sessionId // "unknown"')
USER_PROMPT=$(echo "$PAYLOAD" | jq -r '.prompt // ""')
FILES_MODIFIED=$(echo "$PAYLOAD" | jq -r '.filesModified // []')

# Logging
LOG_DIR="${HOME}/.cursor/logs"
LOG_FILE="${LOG_DIR}/review-on-complete.log"
mkdir -p "$LOG_DIR"

log() {
    echo "[$(date -u +"%Y-%m-%dT%H:%M:%SZ")] $1" >> "$LOG_FILE"
}

log "Agent session completed: sessionId=$SESSION_ID"

# Get changed files from git (more reliable than hook payload)
CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || echo "")
STAGED_FILES=$(git diff --name-only --staged 2>/dev/null || echo "")
ALL_CHANGES=$(echo -e "$CHANGED_FILES\n$STAGED_FILES" | sort -u | grep -v '^$' || true)

if [ -z "$ALL_CHANGES" ]; then
    log "No file changes detected, skipping review"
    exit 0
fi

# Filter for source code files only (exclude docs, configs that don't need review)
SOURCE_EXTENSIONS="ts tsx js jsx py rs go java kt swift rb"
DOC_PATTERNS="\.md$|\.txt$|\.rst$|README|CHANGELOG|LICENSE"

SOURCE_FILES=""
for file in $ALL_CHANGES; do
    # Skip documentation files
    if echo "$file" | grep -qE "$DOC_PATTERNS"; then
        continue
    fi
    
    # Check if it's a source file
    ext="${file##*.}"
    for src_ext in $SOURCE_EXTENSIONS; do
        if [ "$ext" = "$src_ext" ]; then
            SOURCE_FILES="$SOURCE_FILES $file"
            break
        fi
    done
done

SOURCE_FILES=$(echo "$SOURCE_FILES" | xargs)

if [ -z "$SOURCE_FILES" ]; then
    log "No source code changes (docs/config only), skipping review"
    exit 0
fi

SOURCE_COUNT=$(echo "$SOURCE_FILES" | wc -w | xargs)
log "Source files changed: $SOURCE_COUNT"

# Find the most recent spec (if build command was used with a spec)
RECENT_SPEC=""
if [ -d "specs" ]; then
    RECENT_SPEC=$(ls -t specs/*.md 2>/dev/null | head -1 || echo "")
fi

# Create review context file for the review agent
REVIEW_CONTEXT_DIR=".cursor/review-context"
mkdir -p "$REVIEW_CONTEXT_DIR"

CONTEXT_FILE="${REVIEW_CONTEXT_DIR}/${SESSION_ID}.json"

# Build JSON context
cat > "$CONTEXT_FILE" << EOF
{
    "sessionId": "$SESSION_ID",
    "timestamp": "$(date -u +"%Y-%m-%dT%H:%M:%SZ")",
    "trigger": "stop",
    "userPrompt": $(echo "$USER_PROMPT" | jq -Rs .),
    "specFile": "$RECENT_SPEC",
    "sourceFilesChanged": $(echo "$SOURCE_FILES" | tr ' ' '\n' | jq -R . | jq -s .),
    "sourceFileCount": $SOURCE_COUNT,
    "reviewMode": "standard",
    "enforcement": {
        "critical": "blocking",
        "high": "blocking",
        "medium": "advisory",
        "low": "advisory"
    }
}
EOF

log "Review context created: $CONTEXT_FILE"

# Output for agent orchestration
echo "REVIEW_TRIGGERED"
echo "Context: $CONTEXT_FILE"
echo "Source files: $SOURCE_COUNT"
echo "Spec: ${RECENT_SPEC:-none}"

# The review agent will be invoked by the orchestrator reading this output
# and the context file contains everything needed for contextual review

exit 0
