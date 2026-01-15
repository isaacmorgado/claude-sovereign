#!/bin/bash
# Metrics Collector - Build and session metrics
# Based on patterns from: claude-flow MetricsCollector, rushstack HeftMetrics

set -uo pipefail

METRICS_DIR="${HOME}/.claude/metrics"
SESSION_FILE="$METRICS_DIR/session.json"
AGGREGATE_FILE="$METRICS_DIR/aggregate.json"
LOG_FILE="${HOME}/.claude/metrics-collector.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_metrics() {
    mkdir -p "$METRICS_DIR"
    if [[ ! -f "$AGGREGATE_FILE" ]]; then
        cat > "$AGGREGATE_FILE" << 'EOF'
{
    "totalSessions": 0,
    "totalBuilds": 0,
    "totalErrors": 0,
    "totalFixes": 0,
    "totalResearchQueries": 0,
    "successRate": 0,
    "avgBuildTime": 0,
    "avgErrorsPerBuild": 0,
    "topErrors": {},
    "topFixes": {},
    "lastUpdated": null
}
EOF
    fi
}

# =============================================================================
# SESSION METRICS (from rushstack patterns)
# =============================================================================

# Start a new metrics session
start_session() {
    init_metrics

    local session_id
    session_id="session_$(date +%s)"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    cat > "$SESSION_FILE" << EOF
{
    "id": "$session_id",
    "startedAt": "$timestamp",
    "builds": [],
    "errors": [],
    "fixes": [],
    "research": [],
    "checkpoints": [],
    "toolCalls": {},
    "contextUsage": []
}
EOF

    log "Started metrics session: $session_id"
    echo "$session_id"
}

# Record a build
record_build() {
    local build_name="$1"
    local status="$2"
    local duration="${3:-0}"
    local steps="${4:-0}"
    local errors="${5:-0}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        start_session > /dev/null
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg name "$build_name" \
       --arg status "$status" \
       --argjson duration "$duration" \
       --argjson steps "$steps" \
       --argjson errors "$errors" \
       --arg ts "$timestamp" \
       '.builds += [{
           name: $name,
           status: $status,
           duration: $duration,
           steps: $steps,
           errors: $errors,
           timestamp: $ts
       }]' "$SESSION_FILE" > "$temp_file"

    mv "$temp_file" "$SESSION_FILE"

    log "Recorded build: $build_name ($status, ${duration}s, $errors errors)"
}

# Record an error
record_error() {
    local error_type="$1"
    local error_msg="$2"
    local file="${3:-}"
    local resolved="${4:-false}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        start_session > /dev/null
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg type "$error_type" \
       --arg msg "$error_msg" \
       --arg file "$file" \
       --arg resolved "$resolved" \
       --arg ts "$timestamp" \
       '.errors += [{
           type: $type,
           message: $msg,
           file: $file,
           resolved: ($resolved == "true"),
           timestamp: $ts
       }]' "$SESSION_FILE" > "$temp_file"

    mv "$temp_file" "$SESSION_FILE"

    log "Recorded error: $error_type"
}

# Record a fix
record_fix() {
    local error_type="$1"
    local fix_method="$2"
    local source="${3:-manual}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        start_session > /dev/null
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg type "$error_type" \
       --arg method "$fix_method" \
       --arg source "$source" \
       --arg ts "$timestamp" \
       '.fixes += [{
           errorType: $type,
           method: $method,
           source: $source,
           timestamp: $ts
       }]' "$SESSION_FILE" > "$temp_file"

    mv "$temp_file" "$SESSION_FILE"

    log "Recorded fix: $error_type via $fix_method"
}

# Record a research query
record_research() {
    local query="$1"
    local source="$2"
    local results="${3:-0}"
    local useful="${4:-false}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        start_session > /dev/null
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --arg query "$query" \
       --arg source "$source" \
       --argjson results "$results" \
       --arg useful "$useful" \
       --arg ts "$timestamp" \
       '.research += [{
           query: $query,
           source: $source,
           results: $results,
           useful: ($useful == "true"),
           timestamp: $ts
       }]' "$SESSION_FILE" > "$temp_file"

    mv "$temp_file" "$SESSION_FILE"

    log "Recorded research: $source ($results results)"
}

# Record tool usage
record_tool() {
    local tool_name="$1"
    local duration="${2:-0}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        start_session > /dev/null
    fi

    local temp_file
    temp_file=$(mktemp)

    jq --arg tool "$tool_name" \
       --argjson duration "$duration" \
       '.toolCalls[$tool] = ((.toolCalls[$tool] // {count: 0, totalDuration: 0}) |
           .count += 1 | .totalDuration += $duration)' "$SESSION_FILE" > "$temp_file"

    mv "$temp_file" "$SESSION_FILE"
}

# Record context usage
record_context() {
    local percentage="$1"
    local action="${2:-checkpoint}"

    if [[ ! -f "$SESSION_FILE" ]]; then
        start_session > /dev/null
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    jq --argjson pct "$percentage" \
       --arg action "$action" \
       --arg ts "$timestamp" \
       '.contextUsage += [{
           percentage: $pct,
           action: $action,
           timestamp: $ts
       }]' "$SESSION_FILE" > "$temp_file"

    mv "$temp_file" "$SESSION_FILE"

    log "Recorded context: ${percentage}% ($action)"
}

# End session and update aggregates
end_session() {
    if [[ ! -f "$SESSION_FILE" ]]; then
        return 1
    fi

    local temp_file
    temp_file=$(mktemp)

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    # Calculate session stats
    local session_stats
    session_stats=$(jq '
        {
            builds: (.builds | length),
            successful: ([.builds[] | select(.status == "success")] | length),
            errors: (.errors | length),
            fixes: (.fixes | length),
            research: (.research | length),
            duration: (
                (now | floor) - (.startedAt | fromdate | floor)
            )
        }
    ' "$SESSION_FILE")

    # Update aggregate metrics
    local agg_temp
    agg_temp=$(mktemp)

    jq --argjson stats "$session_stats" \
       --arg ts "$timestamp" \
       '
       .totalSessions += 1 |
       .totalBuilds += $stats.builds |
       .totalErrors += $stats.errors |
       .totalFixes += $stats.fixes |
       .totalResearchQueries += $stats.research |
       .successRate = (
           if (.totalBuilds + $stats.builds) > 0 then
               (((.successRate * .totalBuilds) + ($stats.successful)) / (.totalBuilds + $stats.builds) * 100 | floor)
           else 0 end
       ) |
       .lastUpdated = $ts
       ' "$AGGREGATE_FILE" > "$agg_temp"

    mv "$agg_temp" "$AGGREGATE_FILE"

    # Archive session
    local archive_dir="$METRICS_DIR/archive"
    mkdir -p "$archive_dir"
    mv "$SESSION_FILE" "$archive_dir/session_$(date +%Y%m%d_%H%M%S).json"

    log "Ended session, updated aggregates"
    echo "$session_stats"
}

# Get current session metrics
get_session() {
    if [[ ! -f "$SESSION_FILE" ]]; then
        echo '{"status":"no_active_session"}'
        return
    fi

    jq '.' "$SESSION_FILE"
}

# Get aggregate metrics
get_aggregates() {
    init_metrics
    jq '.' "$AGGREGATE_FILE"
}

# Get summary for display
get_summary() {
    init_metrics

    jq -r '
        "=== Build Metrics ===\n" +
        "Total Sessions: \(.totalSessions)\n" +
        "Total Builds: \(.totalBuilds)\n" +
        "Success Rate: \(.successRate)%\n" +
        "Total Errors: \(.totalErrors)\n" +
        "Total Fixes: \(.totalFixes)\n" +
        "Research Queries: \(.totalResearchQueries)\n" +
        "Last Updated: \(.lastUpdated // "never")"
    ' "$AGGREGATE_FILE"
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    start)
        start_session
        ;;
    build)
        record_build "${2:-unnamed}" "${3:-success}" "${4:-0}" "${5:-0}" "${6:-0}"
        ;;
    error)
        record_error "${2:-UNKNOWN}" "${3:-error}" "${4:-}" "${5:-false}"
        ;;
    fix)
        record_fix "${2:-UNKNOWN}" "${3:-manual}" "${4:-manual}"
        ;;
    research)
        record_research "${2:-query}" "${3:-github}" "${4:-0}" "${5:-false}"
        ;;
    tool)
        record_tool "${2:-unknown}" "${3:-0}"
        ;;
    context)
        record_context "${2:-0}" "${3:-checkpoint}"
        ;;
    end)
        end_session
        ;;
    session)
        get_session
        ;;
    aggregates)
        get_aggregates
        ;;
    summary)
        get_summary
        ;;
    help|*)
        echo "Metrics Collector"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Commands:"
        echo "  start                                    - Start new session"
        echo "  build <name> <status> [duration] [steps] [errors]"
        echo "  error <type> <message> [file] [resolved]"
        echo "  fix <error_type> <method> [source]"
        echo "  research <query> <source> [results] [useful]"
        echo "  tool <name> [duration_ms]"
        echo "  context <percentage> [action]"
        echo "  end                                      - End session, update aggregates"
        echo "  session                                  - Get current session"
        echo "  aggregates                               - Get aggregate metrics"
        echo "  summary                                  - Get human-readable summary"
        ;;
esac
