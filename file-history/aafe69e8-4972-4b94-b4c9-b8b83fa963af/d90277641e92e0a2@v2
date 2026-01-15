#!/bin/bash
# PostToolUse Hook: Auto-lint and typecheck after file edits
# Runs silently, fixes what it can, reports issues

set -euo pipefail

LOG_FILE="${HOME}/.claude/quality.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Read hook input
HOOK_INPUT=$(cat)

# Extract tool info
TOOL_NAME=$(echo "$HOOK_INPUT" | jq -r '.tool_name // ""')
TOOL_INPUT=$(echo "$HOOK_INPUT" | jq -r '.tool_input // {}')

# Only run for file modification tools
case "$TOOL_NAME" in
    Write|Edit|MultiEdit|NotebookEdit)
        ;;
    *)
        exit 0
        ;;
esac

# Extract file path
FILE_PATH=$(echo "$TOOL_INPUT" | jq -r '.file_path // .path // ""')

if [[ -z "$FILE_PATH" ]] || [[ ! -f "$FILE_PATH" ]]; then
    exit 0
fi

# Get file extension
EXT="${FILE_PATH##*.}"

log "Quality check triggered for: $FILE_PATH (.$EXT)"

# Run appropriate linter based on file type
case "$EXT" in
    ts|tsx|js|jsx|mjs|cjs)
        # TypeScript/JavaScript - run eslint fix
        if command -v npx &> /dev/null && [[ -f "package.json" ]]; then
            # Check if eslint is available
            if npx eslint --version &> /dev/null 2>&1; then
                LINT_OUTPUT=$(npx eslint --fix "$FILE_PATH" 2>&1) || true
                if [[ -n "$LINT_OUTPUT" ]]; then
                    log "ESLint output: $LINT_OUTPUT"
                    # Return lint issues as advisory (don't block)
                    echo "{\"advisory\": \"ESLint: $(echo "$LINT_OUTPUT" | head -5 | tr '\n' ' ')\"}"
                fi
            fi
        fi
        ;;

    py)
        # Python - run ruff or black
        if command -v ruff &> /dev/null; then
            ruff check --fix "$FILE_PATH" 2>&1 || true
            ruff format "$FILE_PATH" 2>&1 || true
            log "Ruff applied to $FILE_PATH"
        elif command -v black &> /dev/null; then
            black "$FILE_PATH" 2>&1 || true
            log "Black applied to $FILE_PATH"
        fi
        ;;

    go)
        # Go - run gofmt
        if command -v gofmt &> /dev/null; then
            gofmt -w "$FILE_PATH" 2>&1 || true
            log "gofmt applied to $FILE_PATH"
        fi
        ;;

    rs)
        # Rust - run rustfmt
        if command -v rustfmt &> /dev/null; then
            rustfmt "$FILE_PATH" 2>&1 || true
            log "rustfmt applied to $FILE_PATH"
        fi
        ;;

    json)
        # JSON - validate and format with jq
        if command -v jq &> /dev/null; then
            if ! jq empty "$FILE_PATH" 2>&1; then
                log "Invalid JSON in $FILE_PATH"
                echo "{\"advisory\": \"Invalid JSON syntax in $FILE_PATH\"}"
            fi
        fi
        ;;

    *)
        # Unknown file type - skip
        ;;
esac

# ============================================================================
# PHASE 1 INTEGRATION: File Change Detection + Auto-checkpoint
# ============================================================================

# 1. Cache file hash after successful edit
MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"

if [[ -x "$MEMORY_MANAGER" ]]; then
    # Cache file hash for change detection
    hash_result=$("$MEMORY_MANAGER" cache-file "$FILE_PATH" 2>/dev/null || echo "")
    if [[ -n "$hash_result" ]]; then
        log "📝 Cached file hash: $FILE_PATH (${hash_result:0:8}...)"
    fi
fi

# 2. Track file changes and auto-checkpoint every 10 files
FILE_CHANGE_TRACKER="${HOME}/.claude/hooks/file-change-tracker.sh"

if [[ -x "$FILE_CHANGE_TRACKER" ]]; then
    # Record file change
    result=$("$FILE_CHANGE_TRACKER" record "$FILE_PATH" "modified" 2>/dev/null || echo "")

    # Check if checkpoint needed
    if echo "$result" | grep -q "CHECKPOINT_NEEDED"; then
        count=$(echo "$result" | cut -d':' -f2)
        log "⚠️  File change tracker: $count files changed - creating checkpoint"

        # Get list of changed files for advisory
        changed_files=""
        if [[ -x "$FILE_CHANGE_TRACKER" ]]; then
            changed_files=$("$FILE_CHANGE_TRACKER" recent 2>/dev/null | tail -10 | awk '{print $NF}' | tr '\n' ', ' | sed 's/,$//')
        fi

        # Create memory checkpoint automatically (internal state tracking)
        if [[ -x "$MEMORY_MANAGER" ]]; then
            checkpoint_id=$("$MEMORY_MANAGER" checkpoint "Auto-checkpoint after ${count} file changes" 2>/dev/null || echo "")

            if [[ -n "$checkpoint_id" ]]; then
                log "✅ Memory checkpoint created: $checkpoint_id"
            else
                log "⚠️  Failed to create checkpoint"
            fi
        fi

        # Use intelligent command router to decide what to do next
        COMMAND_ROUTER="${SCRIPT_DIR}/autonomous-command-router.sh"
        if [[ -x "$COMMAND_ROUTER" ]]; then
            # Router will decide: advisory (normal mode) or execute_skill (autonomous mode)
            router_decision=$("$COMMAND_ROUTER" execute checkpoint_files "files_changed:${count}" 2>/dev/null || echo '{}')

            # Add checkpoint_id and file list to the output
            if [[ -n "$checkpoint_id" ]]; then
                router_decision=$(echo "$router_decision" | jq --arg cid "$checkpoint_id" '. + {checkpoint_id: $cid}')
            fi
            if [[ -n "$changed_files" ]]; then
                router_decision=$(echo "$router_decision" | jq --arg files "$changed_files" '. + {changed_files: $files}')
            fi

            echo "$router_decision"
        else
            # Fallback if router not available
            echo "{\"advisory\": \"📋 Checkpoint recommended: ${count} files changed. Run /checkpoint to save progress.\"}"
        fi

        # Reset counter after checkpoint
        "$FILE_CHANGE_TRACKER" reset 2>/dev/null || true

        # Regenerate project index for efficient navigation
        PROJECT_NAVIGATOR="${SCRIPT_DIR}/project-navigator.sh"
        if [[ -x "$PROJECT_NAVIGATOR" ]]; then
            log "Regenerating project index after ${count} file changes..."
            "$PROJECT_NAVIGATOR" generate . 4 &>/dev/null || log "⚠️  Project index generation failed"
        fi
    fi
fi

# ============================================================================
# UI TESTING - Auto-test after UI component changes
# ============================================================================
UI_TEST_FRAMEWORK="${HOME}/.claude/hooks/ui-test-framework.sh"

if [[ -x "$UI_TEST_FRAMEWORK" ]] && echo "$FILE_PATH" | grep -qE "(components?|pages?|views?)/.*\.(tsx|jsx)$"; then
    log "UI component modified: $FILE_PATH - checking for test suite"

    # Extract component name
    component_name=$(basename "$FILE_PATH" | sed 's/\.(tsx|jsx)$//')
    suite_name="${component_name}_tests"

    # Check if test suite exists
    if "$UI_TEST_FRAMEWORK" list-suites 2>/dev/null | grep -q "$suite_name"; then
        log "Running UI test suite: $suite_name"

        # Run test suite (no GIF for auto-tests to save time)
        test_result=$("$UI_TEST_FRAMEWORK" run-suite "$suite_name" false 2>&1 || echo "")

        if echo "$test_result" | grep -q "PASS"; then
            log "✅ UI tests passed for $component_name"
        elif echo "$test_result" | grep -q "FAIL"; then
            log "❌ UI tests failed for $component_name"
            echo "{\"advisory\": \"⚠️  UI tests failed for $component_name - check test results\"}"
        fi
    else
        log "No test suite found for $component_name (would be: $suite_name)"
    fi
fi
