#!/bin/bash
# Progress Tracker - Build progress with ETA calculation
# Based on patterns from: elizaOS matrix-orchestrator, rancher-desktop progressTracker

set -uo pipefail

PROGRESS_DIR="${HOME}/.claude/progress"
PROGRESS_FILE="$PROGRESS_DIR/current.json"
HISTORY_FILE="$PROGRESS_DIR/history.json"
LOG_FILE="${HOME}/.claude/progress-tracker.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_progress() {
    mkdir -p "$PROGRESS_DIR"
    if [[ ! -f "$HISTORY_FILE" ]]; then
        echo '{"builds":[]}' > "$HISTORY_FILE"
    fi
}

# =============================================================================
# PROGRESS TRACKING (from elizaOS/rancher-desktop patterns)
# =============================================================================

# Start tracking a new build
start_build() {
    local build_name="$1"
    local total_steps="${2:-0}"

    init_progress

    local build_id
    build_id="build_$(date +%s)"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    cat > "$PROGRESS_FILE" << EOF
{
    "id": "$build_id",
    "name": "$build_name",
    "status": "running",
    "totalSteps": $total_steps,
    "currentStep": 0,
    "completedSteps": [],
    "startedAt": "$timestamp",
    "lastUpdated": "$timestamp",
    "stepDurations": [],
    "estimatedCompletion": null,
    "currentAction": "Starting build..."
}
EOF

    log "Started build: $build_name (id: $build_id, steps: $total_steps)"
    echo "$build_id"
}

# Update current step
update_step() {
    local step_number="$1"
    local step_name="$2"
    local action="${3:-Processing...}"

    if [[ ! -f "$PROGRESS_FILE" ]]; then
        log "No active build to update"
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Calculate ETA based on average step duration
    jq --argjson step "$step_number" \
       --arg name "$step_name" \
       --arg action "$action" \
       --arg ts "$timestamp" \
       '
       . as $root |
       ($root.stepDurations | if length > 0 then (add / length) else 60 end) as $avgDuration |
       (($root.totalSteps - $step) * $avgDuration) as $remainingSeconds |
       (now + $remainingSeconds | strftime("%Y-%m-%dT%H:%M:%SZ")) as $eta |
       .currentStep = $step |
       .currentStepName = $name |
       .currentAction = $action |
       .lastUpdated = $ts |
       .estimatedCompletion = $eta |
       .progress = (if .totalSteps > 0 then ($step / .totalSteps * 100 | floor) else 0 end)
       ' "$PROGRESS_FILE" > "$temp_file"

    mv "$temp_file" "$PROGRESS_FILE"

    log "Updated step: $step_number - $step_name"
}

# Complete a step (records duration for ETA calculation)
complete_step() {
    local step_number="$1"
    local step_name="$2"
    local duration="${3:-0}"

    if [[ ! -f "$PROGRESS_FILE" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --argjson step "$step_number" \
       --arg name "$step_name" \
       --argjson duration "$duration" \
       --arg ts "$timestamp" \
       '
       .completedSteps += [{step: $step, name: $name, duration: $duration, completedAt: $ts}] |
       .stepDurations += [$duration] |
       .lastUpdated = $ts
       ' "$PROGRESS_FILE" > "$temp_file"

    mv "$temp_file" "$PROGRESS_FILE"

    log "Completed step: $step_number - $step_name (${duration}s)"
}

# Mark build as complete
finish_build() {
    local result="${1:-success}"
    local summary="${2:-}"

    if [[ ! -f "$PROGRESS_FILE" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Update progress file
    jq --arg result "$result" \
       --arg summary "$summary" \
       --arg ts "$timestamp" \
       '
       .status = $result |
       .completedAt = $ts |
       .summary = $summary |
       .progress = 100 |
       .totalDuration = (
           (.completedAt | fromdate) - (.startedAt | fromdate) | floor
       )
       ' "$PROGRESS_FILE" > "$temp_file"

    mv "$temp_file" "$PROGRESS_FILE"

    # Add to history
    local history_temp
    history_temp=$(mktemp)

    jq --slurpfile build "$PROGRESS_FILE" \
       '.builds = [$build[0]] + .builds | .builds = .builds[:50]' \
       "$HISTORY_FILE" > "$history_temp"

    mv "$history_temp" "$HISTORY_FILE"

    log "Finished build: $result"
}

# Get current progress
get_progress() {
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo '{"status":"no_active_build"}'
        return
    fi

    jq '.' "$PROGRESS_FILE"
}

# Get progress summary (for display)
get_summary() {
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo "No active build"
        return
    fi

    jq -r '
        "Build: \(.name)\n" +
        "Status: \(.status)\n" +
        "Progress: \(.progress // 0)% (\(.currentStep)/\(.totalSteps) steps)\n" +
        "Current: \(.currentAction // "Idle")\n" +
        "ETA: \(.estimatedCompletion // "Calculating...")"
    ' "$PROGRESS_FILE"
}

# Get build history stats
get_stats() {
    init_progress

    jq '
        .builds as $builds |
        {
            totalBuilds: ($builds | length),
            successful: ([$builds[] | select(.status == "success")] | length),
            failed: ([$builds[] | select(.status == "failed")] | length),
            avgDuration: (
                [$builds[] | select(.totalDuration != null) | .totalDuration] |
                if length > 0 then (add / length | floor) else 0 end
            ),
            avgSteps: (
                [$builds[] | .totalSteps] |
                if length > 0 then (add / length | floor) else 0 end
            ),
            lastBuild: ($builds[0] // null)
        }
    ' "$HISTORY_FILE"
}

# Get ETA for remaining work
get_eta() {
    if [[ ! -f "$PROGRESS_FILE" ]]; then
        echo "unknown"
        return
    fi

    jq -r '.estimatedCompletion // "unknown"' "$PROGRESS_FILE"
}

# Update total steps (if discovered during build)
set_total_steps() {
    local total="$1"

    if [[ ! -f "$PROGRESS_FILE" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    jq --argjson total "$total" '.totalSteps = $total' "$PROGRESS_FILE" > "$temp_file"
    mv "$temp_file" "$PROGRESS_FILE"

    log "Updated total steps to: $total"
}

# Record an error during build
record_error() {
    local error_msg="$1"
    local step="${2:-}"

    if [[ ! -f "$PROGRESS_FILE" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg error "$error_msg" \
       --arg step "$step" \
       --arg ts "$timestamp" \
       '
       .errors = (.errors // []) + [{
           message: $error,
           step: $step,
           timestamp: $ts
       }]
       ' "$PROGRESS_FILE" > "$temp_file"

    mv "$temp_file" "$PROGRESS_FILE"

    log "Recorded error at step $step: $error_msg"
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    start)
        start_build "${2:-unnamed}" "${3:-0}"
        ;;
    update)
        update_step "${2:-0}" "${3:-step}" "${4:-Processing...}"
        ;;
    complete-step)
        complete_step "${2:-0}" "${3:-step}" "${4:-0}"
        ;;
    finish)
        finish_build "${2:-success}" "${3:-}"
        ;;
    progress)
        get_progress
        ;;
    summary)
        get_summary
        ;;
    stats)
        get_stats
        ;;
    eta)
        get_eta
        ;;
    set-total)
        set_total_steps "${2:-0}"
        ;;
    error)
        record_error "${2:-unknown}" "${3:-}"
        ;;
    help|*)
        echo "Progress Tracker"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  start <name> [total_steps]      - Start tracking a build"
        echo "  update <step> <name> [action]   - Update current step"
        echo "  complete-step <step> <name> [duration_secs] - Mark step complete"
        echo "  finish [success|failed] [summary] - Finish build"
        echo "  progress                         - Get full progress JSON"
        echo "  summary                          - Get human-readable summary"
        echo "  stats                            - Get build history stats"
        echo "  eta                              - Get estimated completion time"
        echo "  set-total <steps>                - Update total step count"
        echo "  error <message> [step]           - Record an error"
        ;;
esac
