#!/bin/bash
# Pre-compact hook - saves state before context compaction
# This ensures CLAUDE.md and continuation prompt are always up-to-date

LOG_FILE="${HOME}/.claude/auto-checkpoint.log"
TRIGGER=$(cat | jq -r '.trigger // "unknown"')

echo "[$(date)] Pre-compact triggered (${TRIGGER})" >> "$LOG_FILE"

# Signal to Claude to checkpoint before compacting
# The prompt type hook is more effective here - this just logs
exit 0
