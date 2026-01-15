#!/bin/bash
# Self-Repair Mechanism
# Diagnoses broken scripts and proposes fixes.
# Usage: self-repair.sh <script_path> [error_log]

set -uo pipefail

SCRIPT_PATH="${1:-}"
ERROR_LOG="${2:-}"
LOG_FILE="${HOME}/.claude/self-repair.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

if [[ -z "$SCRIPT_PATH" ]] || [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Usage: $0 <script_path> [error_log]"
    exit 1
fi

log "Diagnosing $SCRIPT_PATH..."

# Read script content
CONTENT=$(cat "$SCRIPT_PATH")

# Construct Prompt
PROMPT="I am an autonomous agent's self-repair system.
The following bash script failed:
Path: $SCRIPT_PATH
Error: ${ERROR_LOG:-"Unknown failure"}

Code:
\`\`\`bash
$CONTENT
\`\`\`

Task:
1. Identify the syntax error or logic bug.
2. Provide a FIXED version of the script.
3. Output ONLY the fixed script code block. No explanation."

# Generate Fix (using aichat or claude)
FIXED_CONTENT=""
if command -v aichat >/dev/null 2>&1; then
    FIXED_CONTENT=$(echo "$PROMPT" | aichat --model claude:sonnet 2>/dev/null || true)
elif command -v claude >/dev/null 2>&1; then
    FIXED_CONTENT=$(echo "$PROMPT" | claude -p "Fix this script" 2>/dev/null || true)
fi

# Clean up output (extract code block)
CLEAN_FIX=$(echo "$FIXED_CONTENT" | sed -n '/^```bash/,/^```/p' | sed '1d;$d')

if [[ -n "$CLEAN_FIX" ]]; then
    # Save proposal
    PROPOSAL_FILE="${SCRIPT_PATH}.fix.proposal"
    echo "$CLEAN_FIX" > "$PROPOSAL_FILE"
    
    # Calculate Diff
    DIFF=$(diff -u "$SCRIPT_PATH" "$PROPOSAL_FILE" || true)
    
    log "Fix proposed for $SCRIPT_PATH"
    log "Diff:\n$DIFF"
    
    echo "🔧 **Self-Repair Proposed**: Fix available for $(basename "$SCRIPT_PATH"). Check ${PROPOSAL_FILE}."
else
    log "Failed to generate fix."
    echo "⚠️  Self-Repair failed to generate a fix."
fi
