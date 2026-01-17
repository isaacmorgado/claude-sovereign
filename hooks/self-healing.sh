#!/bin/bash
# Self-Healing System - Health monitoring and recovery
# Based on patterns from: Roo-Code, claude-flow, medusa, aiometadata

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Find project root: use current directory if .claude exists, otherwise use script parent
find_project_root() {
    if [[ -d "$PWD/.claude" ]]; then
        echo "$PWD"
    else
        echo "$(dirname "$SCRIPT_DIR")"
    fi
}

PROJECT_DIR="$(find_project_root)"
STATE_DIR="${PROJECT_DIR}/.claude"

# Get git branch for memory channel (or default to master)
get_memory_channel() {
    if git rev-parse --git-dir >/dev/null 2>&1; then
        local branch
        branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "master")
        if [[ "$branch" == "HEAD" ]]; then
            branch="master"
        fi
        echo "$branch" | sed 's/[^a-zA-Z0-9_-]/-/g'
    else
        echo "master"
    fi
}

MEMORY_CHANNEL="$(get_memory_channel)"
MEMORY_DIR="${STATE_DIR}/memory/${MEMORY_CHANNEL}"

LOG_FILE="${STATE_DIR}/self-healing.log"
HEALTH_FILE="${STATE_DIR}/health.json"
CIRCUIT_FILE="${STATE_DIR}/circuit-breaker.json"
CHECKPOINT_DIR="${MEMORY_DIR}/checkpoints"

# Thresholds
MAX_ACTION_LOG_SIZE=$((10 * 1024 * 1024))  # 10MB
LOCK_FILE_MAX_AGE=$((60 * 60))  # 1 hour in seconds

# Ensure directories exist
mkdir -p "$STATE_DIR" 2>/dev/null || true
mkdir -p "$MEMORY_DIR" 2>/dev/null || true

log() {
    mkdir -p "$(dirname "$LOG_FILE")" 2>/dev/null || true
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# HEALTH CHECK FUNCTION
# Verifies:
#   - Memory files are valid JSON
#   - Checkpoint directory isn't corrupted
#   - Action log isn't oversized (> 10MB)
#   - No orphaned lock files older than 1 hour
# =============================================================================

health_check() {
    local health_status="healthy"
    local issues=()
    local checks='{}'

    log "Running health check..."

    # Check 1: Memory files are valid JSON
    local json_issues=0
    for json_file in "$MEMORY_DIR"/*.json; do
        if [[ -f "$json_file" ]]; then
            if ! jq empty "$json_file" 2>/dev/null; then
                issues+=("invalid_json:$(basename "$json_file")")
                json_issues=$((json_issues + 1))
                log "Invalid JSON: $json_file"
            fi
        fi
    done

    if [[ $json_issues -gt 0 ]]; then
        health_status="degraded"
    fi

    # Check 2: Checkpoint directory integrity
    local checkpoint_issues=0
    if [[ -d "$CHECKPOINT_DIR" ]]; then
        for ckpt_file in "$CHECKPOINT_DIR"/*.json; do
            if [[ -f "$ckpt_file" ]]; then
                if ! jq empty "$ckpt_file" 2>/dev/null; then
                    issues+=("corrupted_checkpoint:$(basename "$ckpt_file")")
                    checkpoint_issues=$((checkpoint_issues + 1))
                    log "Corrupted checkpoint: $ckpt_file"
                fi
            fi
        done
    fi

    if [[ $checkpoint_issues -gt 0 ]]; then
        health_status="degraded"
    fi

    # Check 3: Action log size (> 10MB is oversized)
    local action_log_oversized="false"
    local action_log="${MEMORY_DIR}/actions.jsonl"
    if [[ -f "$action_log" ]]; then
        local size
        size=$(stat -f%z "$action_log" 2>/dev/null || stat -c%s "$action_log" 2>/dev/null || echo "0")
        if [[ $size -gt $MAX_ACTION_LOG_SIZE ]]; then
            issues+=("oversized_action_log:${size}")
            action_log_oversized="true"
            health_status="degraded"
            log "Oversized action log: ${size} bytes > ${MAX_ACTION_LOG_SIZE}"
        fi
    fi

    # Check 4: Orphaned lock files older than 1 hour
    local orphaned_locks=0
    local now
    now=$(date +%s)

    for lock_file in "$STATE_DIR"/*.lock "$MEMORY_DIR"/.*.lockdir "$MEMORY_DIR"/.memory.lock; do
        if [[ -e "$lock_file" ]]; then
            local lock_mtime
            lock_mtime=$(stat -f%m "$lock_file" 2>/dev/null || stat -c%Y "$lock_file" 2>/dev/null || echo "$now")
            local age=$((now - lock_mtime))

            if [[ $age -gt $LOCK_FILE_MAX_AGE ]]; then
                issues+=("orphaned_lock:$(basename "$lock_file"):${age}s")
                orphaned_locks=$((orphaned_locks + 1))
                log "Orphaned lock file: $lock_file (age: ${age}s)"
            fi
        fi
    done

    if [[ $orphaned_locks -gt 0 ]]; then
        health_status="degraded"
    fi

    # Check 5: Recent error rate from log
    local recent_errors=0
    if [[ -f "$LOG_FILE" ]]; then
        recent_errors=$(tail -100 "$LOG_FILE" 2>/dev/null | grep -c "ERROR\|FAIL\|CRITICAL" || echo "0")
    fi

    if [[ $recent_errors -gt 10 ]]; then
        health_status="unhealthy"
        issues+=("high_error_rate:$recent_errors")
    fi

    # Build checks JSON
    checks=$(jq -n \
        --argjson json_issues "$json_issues" \
        --argjson checkpoint_issues "$checkpoint_issues" \
        --argjson orphaned_locks "$orphaned_locks" \
        --argjson recent_errors "$recent_errors" \
        --arg action_log_oversized "$action_log_oversized" \
        '{
            json_validation_issues: $json_issues,
            checkpoint_issues: $checkpoint_issues,
            orphaned_locks: $orphaned_locks,
            recent_errors: $recent_errors,
            action_log_oversized: ($action_log_oversized == "true")
        }')

    # Convert issues array to JSON
    local issues_json="[]"
    if [[ ${#issues[@]} -gt 0 ]]; then
        issues_json=$(printf '%s\n' "${issues[@]}" | jq -R . | jq -s .)
    fi

    # Save health status
    cat > "$HEALTH_FILE" << EOF
{
    "status": "$health_status",
    "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)",
    "issues": $issues_json,
    "checks": $checks
}
EOF

    log "Health check complete: $health_status (${#issues[@]} issues)"
    echo "$health_status"
}

# =============================================================================
# RECOVERY FUNCTION
# Handles:
#   - Removes stale lock files
#   - Truncates oversized logs
#   - Repairs invalid JSON by restoring from checkpoint
# =============================================================================

recover() {
    local repaired=0

    log "Starting recovery..."

    # Recovery 1: Remove stale lock files
    local now
    now=$(date +%s)

    for lock_file in "$STATE_DIR"/*.lock "$MEMORY_DIR"/.*.lockdir "$MEMORY_DIR"/.memory.lock; do
        if [[ -e "$lock_file" ]]; then
            local lock_mtime
            lock_mtime=$(stat -f%m "$lock_file" 2>/dev/null || stat -c%Y "$lock_file" 2>/dev/null || echo "$now")
            local age=$((now - lock_mtime))

            if [[ $age -gt $LOCK_FILE_MAX_AGE ]]; then
                if [[ -d "$lock_file" ]]; then
                    rmdir "$lock_file" 2>/dev/null && repaired=$((repaired + 1))
                else
                    rm -f "$lock_file" 2>/dev/null && repaired=$((repaired + 1))
                fi
                log "Removed stale lock: $lock_file"
            fi
        fi
    done

    # Recovery 2: Truncate oversized action log
    local action_log="${MEMORY_DIR}/actions.jsonl"
    if [[ -f "$action_log" ]]; then
        local size
        size=$(stat -f%z "$action_log" 2>/dev/null || stat -c%s "$action_log" 2>/dev/null || echo "0")
        if [[ $size -gt $MAX_ACTION_LOG_SIZE ]]; then
            # Keep only last 1000 lines
            local temp_file
            temp_file=$(mktemp)
            tail -1000 "$action_log" > "$temp_file"
            mv "$temp_file" "$action_log"
            repaired=$((repaired + 1))
            log "Truncated oversized action log"
        fi
    fi

    # Recovery 3: Repair invalid JSON files by restoring from checkpoint
    local memory_manager="${SCRIPT_DIR}/memory-manager.sh"
    for json_file in "$MEMORY_DIR"/*.json; do
        if [[ -f "$json_file" ]]; then
            if ! jq empty "$json_file" 2>/dev/null; then
                local basename
                basename=$(basename "$json_file")
                log "Attempting to repair: $basename"

                # Try to restore from latest checkpoint
                if [[ -d "$CHECKPOINT_DIR" ]]; then
                    local latest_ckpt
                    latest_ckpt=$(ls -t "$CHECKPOINT_DIR"/ckpt_*.json 2>/dev/null | head -1)

                    if [[ -n "$latest_ckpt" && -f "$latest_ckpt" ]]; then
                        # Extract the corresponding memory from checkpoint
                        case "$basename" in
                            working.json)
                                jq '.memory.working' "$latest_ckpt" 2>/dev/null > "$json_file" && repaired=$((repaired + 1))
                                ;;
                            episodic.json)
                                jq '.memory.episodic' "$latest_ckpt" 2>/dev/null > "$json_file" && repaired=$((repaired + 1))
                                ;;
                            semantic.json)
                                jq '.memory.semantic' "$latest_ckpt" 2>/dev/null > "$json_file" && repaired=$((repaired + 1))
                                ;;
                            reflections.json)
                                jq '.memory.reflections' "$latest_ckpt" 2>/dev/null > "$json_file" && repaired=$((repaired + 1))
                                ;;
                            *)
                                # For other files, reset to empty JSON object
                                echo '{}' > "$json_file"
                                repaired=$((repaired + 1))
                                ;;
                        esac
                        log "Restored $basename from checkpoint"
                    else
                        # No checkpoint available, reset to default
                        case "$basename" in
                            working.json)
                                echo '{"currentTask":null,"currentContext":[],"recentActions":[],"pendingItems":[],"scratchpad":"","lastUpdated":null}' > "$json_file"
                                ;;
                            episodic.json)
                                echo '{"episodes":[]}' > "$json_file"
                                ;;
                            semantic.json)
                                echo '{"facts":[],"patterns":[],"preferences":[]}' > "$json_file"
                                ;;
                            reflections.json)
                                echo '{"reflections":[]}' > "$json_file"
                                ;;
                            *)
                                echo '{}' > "$json_file"
                                ;;
                        esac
                        repaired=$((repaired + 1))
                        log "Reset $basename to default (no checkpoint available)"
                    fi
                fi
            fi
        fi
    done

    # Recovery 4: Remove corrupted checkpoints
    if [[ -d "$CHECKPOINT_DIR" ]]; then
        for ckpt_file in "$CHECKPOINT_DIR"/*.json; do
            if [[ -f "$ckpt_file" ]]; then
                if ! jq empty "$ckpt_file" 2>/dev/null; then
                    local ckpt_id
                    ckpt_id=$(basename "$ckpt_file" .json)
                    rm -f "$ckpt_file"
                    rm -f "$CHECKPOINT_DIR/${ckpt_id}.actions.jsonl"
                    repaired=$((repaired + 1))
                    log "Removed corrupted checkpoint: $ckpt_id"
                fi
            fi
        done
    fi

    log "Recovery complete: $repaired repairs made"

    # Re-check health
    local new_status
    new_status=$(health_check)

    jq -n \
        --argjson repaired "$repaired" \
        --arg status "$new_status" \
        '{
            repairs_made: $repaired,
            new_status: $status
        }'
}

# =============================================================================
# CIRCUIT BREAKER (prevents repeated failing operations)
# =============================================================================

init_circuit_breaker() {
    if [[ ! -f "$CIRCUIT_FILE" ]]; then
        echo '{"failures":{},"open":{},"openTime":{}}' > "$CIRCUIT_FILE"
    fi
}

is_circuit_open() {
    local operation="$1"
    local threshold="${2:-5}"

    init_circuit_breaker

    local failures
    failures=$(jq -r ".failures[\"$operation\"] // 0" "$CIRCUIT_FILE")
    local is_open
    is_open=$(jq -r ".open[\"$operation\"] // false" "$CIRCUIT_FILE")

    if [[ "$is_open" == "true" ]]; then
        local open_time
        open_time=$(jq -r ".openTime[\"$operation\"] // 0" "$CIRCUIT_FILE")
        local now
        now=$(date +%s)
        local elapsed=$((now - open_time))

        if [[ $elapsed -gt 300 ]]; then
            log "Circuit half-open for $operation (timeout passed)"
            echo "half-open"
            return
        fi
        echo "open"
        return
    fi

    if [[ $failures -ge $threshold ]]; then
        echo "open"
    else
        echo "closed"
    fi
}

record_failure() {
    local operation="$1"

    init_circuit_breaker

    local current
    current=$(jq -r ".failures[\"$operation\"] // 0" "$CIRCUIT_FILE")
    local new_count=$((current + 1))

    local temp_file
    temp_file=$(mktemp)
    jq ".failures[\"$operation\"] = $new_count" "$CIRCUIT_FILE" > "$temp_file"
    mv "$temp_file" "$CIRCUIT_FILE"

    if [[ $new_count -ge 5 ]]; then
        local now
        now=$(date +%s)
        temp_file=$(mktemp)
        jq ".open[\"$operation\"] = true | .openTime[\"$operation\"] = $now" "$CIRCUIT_FILE" > "$temp_file"
        mv "$temp_file" "$CIRCUIT_FILE"
        log "Circuit opened for $operation (failures: $new_count)"
    fi
}

record_success() {
    local operation="$1"

    init_circuit_breaker

    local temp_file
    temp_file=$(mktemp)
    jq ".failures[\"$operation\"] = 0 | .open[\"$operation\"] = false" "$CIRCUIT_FILE" > "$temp_file"
    mv "$temp_file" "$CIRCUIT_FILE"

    log "Circuit reset for $operation"
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    health)
        health_check
        ;;
    recover)
        recover
        ;;
    status)
        if [[ -f "$HEALTH_FILE" ]]; then
            cat "$HEALTH_FILE"
        else
            health_check >/dev/null
            cat "$HEALTH_FILE"
        fi
        ;;
    circuit-check)
        is_circuit_open "${2:-default}"
        ;;
    circuit-fail)
        record_failure "${2:-default}"
        ;;
    circuit-success)
        record_success "${2:-default}"
        ;;
    help|*)
        echo "Self-Healing System - Health monitoring and recovery"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  health              - Run comprehensive health check"
        echo "  recover             - Attempt to repair all issues"
        echo "  status              - Show current health status JSON"
        echo "  circuit-check <op>  - Check if circuit is open for operation"
        echo "  circuit-fail <op>   - Record a failure for operation"
        echo "  circuit-success <op>- Record success (resets circuit)"
        echo ""
        echo "Health check verifies:"
        echo "  - Memory files are valid JSON"
        echo "  - Checkpoint directory integrity"
        echo "  - Action log isn't oversized (> 10MB)"
        echo "  - No orphaned lock files (> 1 hour old)"
        echo ""
        echo "Health status values: healthy, degraded, unhealthy"
        ;;
esac
