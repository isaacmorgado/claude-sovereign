#!/bin/bash
# Auto-Continue Hook - Fully automated context management with quality awareness
# V2 Enhanced with: context event tracking, sliding window fallback
# When context hits threshold:
# 1. Checks if build is in progress
# 2. Runs validation before checkpoint
# 3. Saves state and creates continuation prompt
# 4. Feeds prompt back to keep running

set -euo pipefail

THRESHOLD=${CLAUDE_CONTEXT_THRESHOLD:-40}
LOG_FILE="${HOME}/.claude/auto-continue.log"
STATE_FILE=".claude/auto-continue.local.md"
BUILD_STATE=".claude/current-build.local.md"

# V2 Integration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
EVENT_TRACKER="${SCRIPT_DIR}/context-event-tracker.sh"
SLIDING_WINDOW="${SCRIPT_DIR}/sliding-window.sh"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Read hook input
HOOK_INPUT=$(cat)

# Extract context info
CONTEXT_SIZE=$(echo "$HOOK_INPUT" | jq -r '.context_window.context_window_size // 200000')
USAGE=$(echo "$HOOK_INPUT" | jq '.context_window.current_usage // null')
TRANSCRIPT_PATH=$(echo "$HOOK_INPUT" | jq -r '.transcript_path // ""')

if [[ "$USAGE" == "null" ]]; then
    log "No usage data - allowing stop"
    exit 0
fi

# Calculate percentage
INPUT_TOKENS=$(echo "$USAGE" | jq -r '.input_tokens // 0')
CACHE_CREATE=$(echo "$USAGE" | jq -r '.cache_creation_input_tokens // 0')
CACHE_READ=$(echo "$USAGE" | jq -r '.cache_read_input_tokens // 0')
CURRENT_TOKENS=$((INPUT_TOKENS + CACHE_CREATE + CACHE_READ))
PERCENT=$((CURRENT_TOKENS * 100 / CONTEXT_SIZE))

log "Context: ${PERCENT}% (${CURRENT_TOKENS}/${CONTEXT_SIZE})"

# Check if auto-continue is disabled
if [[ -f ".claude/auto-continue-disabled" ]]; then
    log "Auto-continue disabled - allowing stop"
    exit 0
fi

# Check for stop words in last message
if [[ -n "$TRANSCRIPT_PATH" ]] && [[ -f "$TRANSCRIPT_PATH" ]]; then
    LAST_USER=$(grep '"role":"user"' "$TRANSCRIPT_PATH" | tail -1 | jq -r '.message.content[0].text // ""' 2>/dev/null || echo "")
    if echo "$LAST_USER" | grep -qiE '\b(stop|pause|hold|wait|quit)\b'; then
        log "Stop word detected - allowing stop"
        exit 0
    fi
fi

# Below threshold - allow normal stop
if [[ $PERCENT -lt $THRESHOLD ]]; then
    exit 0
fi

log "Threshold reached (${PERCENT}% >= ${THRESHOLD}%) - triggering auto-continue"

# PHASE 1 & 4 INTEGRATION: Check context budget and create checkpoint
log "Checking memory context budget..."
MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"
CHECKPOINT_ID=""

if [[ -x "$MEMORY_MANAGER" ]]; then
    # PHASE 4: Check context budget (pass current percentage)
    CONTEXT_USAGE=$("$MEMORY_MANAGER" context-usage "$PERCENT" 2>/dev/null || echo "{}")
    CONTEXT_STATUS=$(echo "$CONTEXT_USAGE" | jq -r '.status // "unknown"' 2>/dev/null || echo "unknown")

    if [[ "$CONTEXT_STATUS" == "critical" || "$CONTEXT_STATUS" == "warning" ]]; then
        log "⚠️  Memory context budget at warning/critical - compacting memory..."

        # V2: Log event before compaction
        local before_tokens=$CURRENT_TOKENS

        # Attempt compaction
        if "$MEMORY_MANAGER" context-compact 2>/dev/null; then
            log "✅ Memory compaction successful"

            # V2: Log successful compaction event
            if [[ -x "$EVENT_TRACKER" ]]; then
                local after_tokens=$((CURRENT_TOKENS * 70 / 100))  # Estimate 30% reduction
                "$EVENT_TRACKER" log compact_memory "$before_tokens" "$after_tokens" "auto" "true" "" 2>/dev/null || true
            fi
        else
            log "⚠️  Memory compact failed - trying sliding window fallback"

            # V2: Sliding window fallback
            if [[ -x "$SLIDING_WINDOW" ]]; then
                local strategy=$("$SLIDING_WINDOW" strategy "$CURRENT_TOKENS" "$CONTEXT_SIZE" 2>/dev/null || echo '{}')
                local should_truncate=$(echo "$strategy" | jq -r '.shouldTruncate // "false"')

                if [[ "$should_truncate" == "true" ]]; then
                    log "📉 Applying sliding window truncation"
                    local plan=$("$SLIDING_WINDOW" truncate "$CURRENT_TOKENS" "$CONTEXT_SIZE" 60 2>/dev/null || echo '{}')
                    local target=$(echo "$plan" | jq -r '.targetTokens // 0')

                    # Log event
                    if [[ -x "$EVENT_TRACKER" ]]; then
                        "$EVENT_TRACKER" log sliding_window "$before_tokens" "$target" "fallback" "true" "Compaction failed, used fallback" 2>/dev/null || true
                    fi
                fi
            fi
        fi
    fi

    # PHASE 1: Create checkpoint with context percentage in description
    log "Creating memory checkpoint before Claude context compact..."
    CHECKPOINT_ID=$("$MEMORY_MANAGER" checkpoint "Auto-checkpoint at ${PERCENT}% context before compact" 2>/dev/null || echo "")

    if [[ -n "$CHECKPOINT_ID" ]]; then
        log "✅ Memory checkpoint created: $CHECKPOINT_ID"
    else
        log "⚠️  Failed to create memory checkpoint"
    fi
else
    log "⚠️  memory-manager.sh not found - skipping checkpoint"
fi

# Get current working directory info
PROJECT_NAME=$(basename "$(pwd)")
PROJECT_DIR=$(pwd)

# Check if build is in progress
BUILD_CONTEXT=""
if [[ -f "$BUILD_STATE" ]]; then
    BUILD_FEATURE=$(grep '^feature:' "$BUILD_STATE" | sed 's/feature: *//' || echo "")
    BUILD_PHASE=$(grep '^phase:' "$BUILD_STATE" | sed 's/phase: *//' || echo "")
    BUILD_ITERATION=$(grep '^iteration:' "$BUILD_STATE" | sed 's/iteration: *//' || echo "1")

    if [[ -n "$BUILD_FEATURE" ]] && [[ "$BUILD_PHASE" != "complete" ]]; then
        BUILD_CONTEXT="
**Active Build**: $BUILD_FEATURE (phase: $BUILD_PHASE, iteration: $BUILD_ITERATION)
Continue implementing this feature. Check .claude/current-build.local.md for progress."
    fi
fi

# Read CLAUDE.md if exists
CLAUDE_MD_CONTENT=""
if [[ -f "CLAUDE.md" ]]; then
    CLAUDE_MD_CONTENT=$(head -50 CLAUDE.md 2>/dev/null || echo "")
fi

# Read buildguide.md next section if exists
NEXT_SECTION=""
NEXT_SECTION_DETAIL=""
if [[ -f "buildguide.md" ]]; then
    # Get first unchecked section
    NEXT_SECTION=$(grep -m1 '^\- \[ \]' buildguide.md 2>/dev/null | sed 's/- \[ \] //' || echo "")

    # Try to get the section details
    if [[ -n "$NEXT_SECTION" ]]; then
        # Find the section header and get content until next section
        SECTION_CONTENT=$(awk "/^## .*${NEXT_SECTION}/,/^## /" buildguide.md 2>/dev/null | head -30 || echo "")
        if [[ -n "$SECTION_CONTENT" ]]; then
            NEXT_SECTION_DETAIL="
**Next Section from buildguide.md**: $NEXT_SECTION
$SECTION_CONTENT"
        fi
    fi
fi

# Check for architecture docs
ARCH_CONTEXT=""
for arch_file in "ARCHITECTURE.md" "docs/architecture.md" ".claude/docs/architecture.md"; do
    if [[ -f "$arch_file" ]]; then
        ARCH_CONTEXT="
**Architecture**: See $arch_file for system design."
        break
    fi
done

# Check for stuck issues in debug-log
STUCK_ISSUES=""
if [[ -f ".claude/docs/debug-log.md" ]]; then
    STUCK=$(grep -c "STUCK" ".claude/docs/debug-log.md" 2>/dev/null || echo "0")
    STUCK=$(echo "$STUCK" | tr -d '\n' | tr -d ' ')
    if [[ -n "$STUCK" ]] && [[ "$STUCK" =~ ^[0-9]+$ ]] && [[ "$STUCK" -gt 0 ]]; then
        STUCK_ISSUES="
⚠️ $STUCK stuck issues in debug-log.md - may need review."
    fi
fi

# Run Proactive Janitor (Tech Debt & Security Scan)
JANITOR_HOOK="${HOME}/.claude/hooks/proactive-janitor.sh"
JANITOR_REPORT=""
if [[ -x "$JANITOR_HOOK" ]]; then
    log "Running Proactive Janitor scan..."
    JANITOR_REPORT=$("$JANITOR_HOOK" 2>/dev/null || echo "")
fi

# Build continuation prompt (token-effective per Ken Kai principles)
# Principles: Short > Long, Don't Dump, Reference existing context
CHECKPOINT_INFO=""
if [[ -n "$CHECKPOINT_ID" ]]; then
    CHECKPOINT_INFO="
MemID: $CHECKPOINT_ID"
fi

# Use intelligent command router to determine checkpoint action
COMMAND_ROUTER="${HOME}/.claude/hooks/autonomous-command-router.sh"
ROUTER_DECISION=""
SHOULD_EXECUTE_CHECKPOINT="false"

if [[ -x "$COMMAND_ROUTER" ]]; then
    ROUTER_OUTPUT=$("$COMMAND_ROUTER" execute checkpoint_context "${CURRENT_TOKENS}/${CONTEXT_SIZE}" 2>/dev/null || echo '{}')

    # Check if autonomous execution is signaled
    EXECUTE_SKILL=$(echo "$ROUTER_OUTPUT" | jq -r '.execute_skill // ""')
    if [[ "$EXECUTE_SKILL" == "checkpoint" ]]; then
        SHOULD_EXECUTE_CHECKPOINT="true"
        ROUTER_DECISION="$ROUTER_OUTPUT"
        log "Router decided: Auto-execute /checkpoint"
    fi
fi

# Force autonomous mode if Loop is active (Critical for true autonomy)
if [[ "${CLAUDE_LOOP_ACTIVE:-0}" == "1" ]]; then
    if [[ "$SHOULD_EXECUTE_CHECKPOINT" != "true" ]]; then
        SHOULD_EXECUTE_CHECKPOINT="true"
        # Create default router decision if none exists
        if [[ -z "$ROUTER_DECISION" ]]; then
            ROUTER_DECISION='{"execute_skill": "checkpoint", "reason": "loop_mode_enforced", "autonomous": true}'
        fi
        log "Loop active: Forcing autonomous checkpoint execution"
    fi
fi

# DIRECT EXECUTION FUNCTION - Execute checkpoint without Claude signaling
execute_checkpoint_directly() {
    log "🚀 Executing checkpoint directly in hook (bypassing Claude signal)"

    # Check if we're in a git repo
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log "⚠️  Not in a git repository - skipping direct checkpoint"
        return 1
    fi

    # Check if there are changes to commit
    if git diff --quiet && git diff --cached --quiet; then
        log "✅ No changes to commit - checkpoint unnecessary"
        return 0
    fi

    # Update CLAUDE.md with session progress
    local claude_md="CLAUDE.md"
    if [[ -f "$claude_md" ]]; then
        log "📝 Updating CLAUDE.md with session progress"

        # Create a simple session summary
        local timestamp=$(date '+%Y-%m-%d %H:%M')

        # Write session summary to temp file for awk to read
        local temp_summary="/tmp/claude-session-summary-$$.md"
        cat > "$temp_summary" <<EOF
### Last Session ($timestamp)

**Auto-checkpoint triggered at ${PERCENT}% context**
- Context reached threshold: ${CURRENT_TOKENS}/${CONTEXT_SIZE} tokens
- Session iteration: $ITERATION
${BUILD_CONTEXT:+- Build in progress: $BUILD_FEATURE}
${CHECKPOINT_ID:+- Memory checkpoint: $CHECKPOINT_ID}

Stopped at: Context threshold reached, auto-checkpoint executed
EOF

        # Simple update: append to or update "Last Session" section
        # This is a minimal update - full CLAUDE.md management stays in /checkpoint command
        if grep -q "## Last Session" "$claude_md" 2>/dev/null; then
            # Update existing Last Session section using Python for reliable multi-line handling
            if python3 <<PYEOF 2>&1 | tee -a "$LOG_FILE"
import re

with open("$claude_md", 'r') as f:
    content = f.read()

with open("$temp_summary", 'r') as f:
    new_session = f.read()

# Replace from "## Last Session" (with optional date/text) to the next "##" (or EOF)
# Pattern: ## Last Session... anything until next ## or end of file
pattern = r'## Last Session[^\n]*\n.*?(?=\n##|\Z)'
replacement = '## Last Session\n\n' + new_session

result = re.sub(pattern, replacement, content, flags=re.DOTALL)

with open("$claude_md", 'w') as f:
    f.write(result)
PYEOF
            then
                log "✅ Updated existing Last Session in CLAUDE.md"
            else
                log "❌ Python update failed, trying simple append"
                # Fallback: just append
                echo -e "\n### Auto-Checkpoint $(date '+%Y-%m-%d %H:%M')" >> "$claude_md"
                cat "$temp_summary" >> "$claude_md"
            fi
        else
            # Append Last Session section
            echo -e "\n## Last Session\n" >> "$claude_md"
            cat "$temp_summary" >> "$claude_md"
            log "✅ Added Last Session to CLAUDE.md"
        fi

        rm -f "$temp_summary"
        log "📋 CLAUDE.md update complete, proceeding to git operations"
    else
        log "⚠️  CLAUDE.md not found - creating minimal version"
        cat > "$claude_md" <<EOF
# $PROJECT_NAME

Auto-generated checkpoint at $(date '+%Y-%m-%d %H:%M')

## Current Focus
Section: Context management
Files: Auto-checkpoint triggered at ${PERCENT}% context

## Last Session ($(date '+%Y-%m-%d'))
- Auto-checkpoint at ${PERCENT}% context
- Stopped at: Context threshold reached

## Next Steps
1. Resume work - check continuation prompt
2. Review progress in git log
EOF
        log "✅ Created minimal CLAUDE.md"
    fi

    # Stage the changes
    log "📦 Staging changes to git..."
    if git add CLAUDE.md buildguide.md 2>&1 | tee -a "$LOG_FILE"; then
        log "✅ Files staged successfully"
    elif git add CLAUDE.md 2>&1 | tee -a "$LOG_FILE"; then
        log "✅ CLAUDE.md staged (buildguide.md not found)"
    else
        log "❌ Failed to stage files"
        return 1
    fi

    # Check again if there are actually staged changes
    log "🔍 Checking for staged changes..."
    if git diff --cached --quiet; then
        log "✅ No staged changes after adding files - nothing to commit"
        return 0
    fi
    log "✅ Staged changes detected, proceeding with commit"

    # Commit with auto-checkpoint message
    log "💾 Creating git commit..."

    # Use a temp file for the commit message to handle multi-line properly
    local commit_msg_file="/tmp/claude-commit-msg-$$.txt"
    cat > "$commit_msg_file" <<'COMMITMSG_EOF'
checkpoint: auto-checkpoint

Auto-checkpoint triggered by context threshold.

Co-Authored-By: Claude Sonnet 4.5 <noreply@anthropic.com>
COMMITMSG_EOF

    log "📄 Commit message file created at $commit_msg_file"

    # Commit using -F for file input
    local git_output
    local git_exit_code
    git_output=$(git commit -F "$commit_msg_file" 2>&1) || git_exit_code=$?
    log "Git commit exit code: ${git_exit_code:-0}"
    log "Git commit output: $git_output"

    if [[ "${git_exit_code:-0}" -eq 0 ]]; then
        echo "$git_output" | tee -a "$LOG_FILE"
        rm -f "$commit_msg_file"
        log "✅ Git commit successful"

        # Push to remote if it exists
        if git remote | grep -q 'origin'; then
            log "📤 Pushing to remote..."
            local push_output
            if push_output=$(git push origin HEAD 2>&1); then
                echo "$push_output" | tee -a "$LOG_FILE"
                log "✅ Git push successful"
                return 0
            else
                echo "$push_output" | tee -a "$LOG_FILE"
                log "⚠️  Git push failed - local commit still created"
                return 0  # Still count as success since local commit worked
            fi
        else
            log "✅ No remote configured - local commit only"
            return 0
        fi
    else
        echo "$git_output" | tee -a "$LOG_FILE"
        rm -f "$commit_msg_file"
        log "❌ Git commit failed: $git_output"
        return 1
    fi
}

# Execute checkpoint directly if in autonomous mode
CHECKPOINT_EXECUTED="false"
if [[ "$SHOULD_EXECUTE_CHECKPOINT" == "true" ]]; then
    log "Attempting direct checkpoint execution..."
    if execute_checkpoint_directly; then
        CHECKPOINT_EXECUTED="true"
        log "✅ Direct checkpoint execution completed successfully"
    else
        log "⚠️  Direct checkpoint execution failed - falling back to Claude signal"
    fi
fi

# Build continuation prompt based on autonomous mode and checkpoint execution status
if [[ "$SHOULD_EXECUTE_CHECKPOINT" == "true" && "$CHECKPOINT_EXECUTED" == "true" ]]; then
    # CHECKPOINT ALREADY EXECUTED - Just inform and continue
    if [[ "${CLAUDE_LOOP_ACTIVE:-0}" == "1" ]]; then
        # LOOP MODE: Checkpoint done, session can exit
        CURRENT_INSTRUCTION="**AUTO-CONTINUE**: Context ${PERCENT}% full - ✅ checkpoint executed automatically.

**What happened:**
- CLAUDE.md updated with session progress
- Changes committed to git
- Pushed to GitHub (if remote exists)

**Next:**
- Session will terminate to free context
- Loop will auto-restart with saved state
- Work continues seamlessly"
    else
        # MANUAL AUTONOMY: Checkpoint done, inform user
        CURRENT_INSTRUCTION="**AUTO-CONTINUE**: Context ${PERCENT}% full - ✅ checkpoint executed automatically.

**What happened:**
- CLAUDE.md updated with session progress
- Changes committed to git
- Pushed to GitHub (if remote exists)

**Next:**
- Resume with: \`aichat resume\` OR
- Clear context: \`/clear\` then paste continuation prompt below"
    fi

    # The actual prompt for the NEXT session
    CONTINUATION_PROMPT="**RESUME**: ${PROJECT_NAME} (checkpoint auto-saved).
**Context**:
${BUILD_CONTEXT:-* Check .claude/current-build.local.md or buildguide.md}
${NEXT_SECTION:+* Next: $NEXT_SECTION}
${CHECKPOINT_INFO}
${JANITOR_REPORT}

**Note**: Last session auto-checkpointed at ${PERCENT}% context. All progress saved to git.

**Goal**: Continue immediately. No questions. /auto"

elif [[ "$SHOULD_EXECUTE_CHECKPOINT" == "true" ]]; then
    # AUTONOMOUS MODE BUT EXECUTION FAILED - Signal Claude to execute
    if [[ "${CLAUDE_LOOP_ACTIVE:-0}" == "1" ]]; then
        # LOOP MODE: Instruct to execute checkpoint
        CURRENT_INSTRUCTION="**AUTO-CONTINUE**: Context ${PERCENT}% full - executing checkpoint now.

<command-name>/checkpoint</command-name>

After checkpoint completes:
- Session will terminate to free context
- Loop will auto-restart with saved state"
    else
        # MANUAL AUTONOMY: Instruct to execute checkpoint
        CURRENT_INSTRUCTION="**AUTO-CONTINUE**: Context ${PERCENT}% full - executing checkpoint now.

<command-name>/checkpoint</command-name>

After checkpoint completes:
- Resume with: \`aichat resume\` OR
- Clear context: \`/clear\` then paste continuation prompt"
    fi

    # The actual prompt for the NEXT session
    CONTINUATION_PROMPT="**RESUME**: ${PROJECT_NAME} (${PERCENT}% context).
**Context**:
${BUILD_CONTEXT:-* Check .claude/current-build.local.md or buildguide.md}
${NEXT_SECTION:+* Next: $NEXT_SECTION}
${CHECKPOINT_INFO}
${JANITOR_REPORT}

**Goal**: Continue immediately. No questions. /auto"

else
    # NORMAL MODE - Concise per Ken's Guide
    CURRENT_INSTRUCTION="**RESUME**: ${PROJECT_NAME} (${PERCENT}% context).
${BUILD_CONTEXT}
${NEXT_SECTION:+Next: $NEXT_SECTION}
${CHECKPOINT_INFO}
${STUCK_ISSUES}
${JANITOR_REPORT}

**Action**: Run \`/checkpoint\` to save.
**Then**: \`aichat resume\` OR \`/clear\` & paste this context.

**Focus**: ${NEXT_SECTION:-Current Task}. Reference docs/plans. Don't re-read entire codebase."

    CONTINUATION_PROMPT="$CURRENT_INSTRUCTION"
fi

# Track iteration
ITERATION=1
if [[ -f "$STATE_FILE" ]]; then
    ITERATION=$(grep '^iteration:' "$STATE_FILE" | sed 's/iteration: *//' || echo "1")
    ITERATION=$((ITERATION + 1))
fi

# Create/update state file
mkdir -p .claude
cat > "$STATE_FILE" <<EOF
---
active: true
iteration: $ITERATION
threshold: $THRESHOLD
last_percent: $PERCENT
last_compact: "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
build_active: $(if [[ -n "$BUILD_CONTEXT" ]]; then echo "true"; else echo "false"; fi)
---

Auto-continue active. Iteration ${ITERATION}.
EOF

# Output JSON to block stop and feed continuation prompt
# Include router decision for autonomous skill execution
SYSTEM_MSG="Auto-continue: Context ${PERCENT}% compacted (iteration ${ITERATION})${BUILD_CONTEXT:+ | Build: $BUILD_FEATURE}"

if [[ "$SHOULD_EXECUTE_CHECKPOINT" == "true" ]]; then
    # Autonomous mode: Include execution metadata
    if [[ "$CHECKPOINT_EXECUTED" == "true" ]]; then
        # Checkpoint was executed directly - inform Claude
        jq -n \
            --arg prompt "$CURRENT_INSTRUCTION" \
            --arg msg "$SYSTEM_MSG | ✅ Auto-checkpoint executed (CLAUDE.md updated, changes committed & pushed)" \
            --argjson router "$ROUTER_DECISION" \
            '{
                "decision": "block",
                "reason": $prompt,
                "systemMessage": $msg,
                "autonomous_execution": {
                    "enabled": true,
                    "skill": "checkpoint",
                    "reason": "context_threshold",
                    "executed_directly": true,
                    "router_decision": $router
                }
            }'
    else
        # Direct execution failed - signal Claude to execute
        jq -n \
            --arg prompt "$CURRENT_INSTRUCTION" \
            --arg msg "$SYSTEM_MSG | ⚠️  Direct checkpoint failed - Claude should execute /checkpoint" \
            --argjson router "$ROUTER_DECISION" \
            '{
                "decision": "block",
                "reason": $prompt,
                "systemMessage": $msg,
                "autonomous_execution": {
                    "enabled": true,
                    "skill": "checkpoint",
                    "reason": "context_threshold",
                    "executed_directly": false,
                    "router_decision": $router
                }
            }'
    fi
else
    # Normal mode: Just continuation prompt
    jq -n \
        --arg prompt "$CURRENT_INSTRUCTION" \
        --arg msg "$SYSTEM_MSG" \
        '{
            "decision": "block",
            "reason": $prompt,
            "systemMessage": $msg
        }'
fi

# Write continuation prompt to file for claude-loop.sh handoff
# This enables true autonomy - loop picks up prompt on restart
HANDOFF_FILE="${HOME}/.claude/continuation-prompt.md"
echo "$CONTINUATION_PROMPT" > "$HANDOFF_FILE"
log "Wrote continuation prompt to $HANDOFF_FILE"

log "Auto-continue triggered - iteration $ITERATION"
exit 0
