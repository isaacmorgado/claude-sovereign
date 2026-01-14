#!/bin/bash
# Self-Healing - System Health Monitoring and Recovery
# Monitors system health, detects issues, and triggers automatic recovery
# Usage: self-healing.sh check | heal | monitor

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/self-healing.log"
STATE_FILE="${HOME}/.claude/self-healing-state.json"
ALERT_FILE="${HOME}/.claude/self-healing-alerts.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"
mkdir -p "$(dirname "$ALERT_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "health_checks": [],
    "recovery_actions": [],
    "metrics": {
        "total_checks": 0,
        "failed_checks": 0,
        "successful_recoveries": 0,
        "failed_recoveries": 0
    }
}
EOF
    fi

    if [[ ! -f "$ALERT_FILE" ]]; then
        cat > "$ALERT_FILE" << 'EOF'
{
    "active_alerts": [],
    "alert_history": []
}
EOF
    fi
}

# Check system health
check() {
    init_state
    log "Performing system health check"

    local checks=()
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Check 1: File system space
    local disk_usage
    disk_usage=$(df -h "$HOME" | awk 'NR==2 {print $5}' | tr -d '%')
    local disk_status="healthy"
    if [[ $disk_usage -gt 90 ]]; then
        disk_status="critical"
    elif [[ $disk_usage -gt 80 ]]; then
        disk_status="warning"
    fi

    checks+=('{
        "id": "disk_space",
        "name": "File System Space",
        "status": "'"$disk_status"'",
        "value": '"$disk_usage"',
        "threshold": 80,
        "message": "Disk usage at '"$disk_usage"'%"
    }')

    # Check 2: Memory availability
    local memory_info
    if command -v free &> /dev/null; then
        memory_info=$(free -m | awk 'NR==2 {printf "%.0f", ($7/$2)*100}')
    else
        # macOS
        memory_info=$(vm_stat | awk 'NR==2 {printf "%.0f", ($4/4096)/($4/4096 + $3/4096)*100}')
    fi

    local memory_status="healthy"
    if [[ $memory_info -lt 10 ]]; then
        memory_status="critical"
    elif [[ $memory_info -lt 20 ]]; then
        memory_status="warning"
    fi

    checks+=('{
        "id": "memory",
        "name": "Memory Availability",
        "status": "'"$memory_status"'",
        "value": '"$memory_info"',
        "threshold": 20,
        "message": "Memory available: '"$memory_info"'%"
    }')

    # Check 3: Log file size
    local log_size
    log_size=$(du -m "$LOG_FILE" 2>/dev/null | cut -f1 || echo "0")

    local log_status="healthy"
    if [[ $log_size -gt 100 ]]; then
        log_status="warning"
    fi

    checks+=('{
        "id": "log_size",
        "name": "Log File Size",
        "status": "'"$log_status"'",
        "value": '"$log_size"',
        "threshold": 100,
        "message": "Log file size: '"$log_size"' MB"
    }')

    # Check 4: State file integrity
    local state_status="healthy"
    if ! jq -e '.' "$STATE_FILE" > /dev/null 2>&1; then
        state_status="critical"
    fi

    checks+=('{
        "id": "state_integrity",
        "name": "State File Integrity",
        "status": "'"$state_status"'",
        "value": 100,
        "threshold": 100,
        "message": "State file '"$state_status"'"
    }')

    # Check 5: Recent errors in log
    local error_count
    error_count=$(grep -c "ERROR\|CRITICAL\|FATAL" "$LOG_FILE" 2>/dev/null | tail -1 || echo "0")

    local error_status="healthy"
    if [[ $error_count -gt 50 ]]; then
        error_status="critical"
    elif [[ $error_count -gt 20 ]]; then
        error_status="warning"
    fi

    checks+=('{
        "id": "error_rate",
        "name": "Recent Error Rate",
        "status": "'"$error_status"'",
        "value": '"$error_count"',
        "threshold": 20,
        "message": "Recent errors: '"$error_count"'"
    }')

    # Convert checks to JSON
    local checks_json
    checks_json=$(printf '%s\n' "${checks[@]}" | jq -s '.')

    # Determine overall health
    local overall_status="healthy"
    local critical_count
    critical_count=$(echo "$checks_json" | jq '[.[] | select(.status == "critical")] | length')

    local warning_count
    warning_count=$(echo "$checks_json" | jq '[.[] | select(.status == "warning")] | length')

    if [[ $critical_count -gt 0 ]]; then
        overall_status="critical"
    elif [[ $warning_count -gt 0 ]]; then
        overall_status="warning"
    fi

    # Record health check
    local health_check
    health_check=$(jq -n \
        --arg timestamp "$timestamp" \
        --argjson checks "$checks_json" \
        --arg status "$overall_status" \
        '{
            timestamp: $timestamp,
            checks: $checks,
            overall_status: $status,
            critical_count: ($checks | map(select(.status == "critical")) | length),
            warning_count: ($checks | map(select(.status == "warning")) | length)
        }')

    jq ".health_checks += [$health_check]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Update metrics
    jq ".metrics.total_checks += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    if [[ $overall_status != "healthy" ]]; then
        jq ".metrics.failed_checks += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi

    # Create alerts for critical issues
    if [[ $critical_count -gt 0 ]]; then
        local critical_checks
        critical_checks=$(echo "$checks_json" | jq '[.[] | select(.status == "critical")]')

        local alert
        alert=$(jq -n \
            --arg timestamp "$timestamp" \
            --argjson checks "$critical_checks" \
            '{
                id: "alert_" + (now | tostring),
                timestamp: $timestamp,
                severity: "critical",
                checks: $checks,
                message: "Critical health issues detected"
            }')

        jq ".active_alerts += [$alert]" "$ALERT_FILE" > "${ALERT_FILE}.tmp"
        mv "${ALERT_FILE}.tmp" "$ALERT_FILE"
    fi

    log "Health check complete: $overall_status ($critical_count critical, $warning_count warning)"

    # Output result
    jq -n \
        --arg timestamp "$timestamp" \
        --argjson checks "$checks_json" \
        --arg status "$overall_status" \
        --argjson critical_count "$critical_count" \
        --argjson warning_count "$warning_count" \
        '{
            timestamp: $timestamp,
            overall_status: $status,
            critical_count: $critical_count,
            warning_count: $warning_count,
            checks: $checks,
            needs_healing: ($status != "healthy")
        }'
}

# Heal detected issues
heal() {
    init_state
    log "Starting self-healing process"

    # Get current health status
    local health_result
    health_result=$(check)

    local needs_healing
    needs_healing=$(echo "$health_result" | jq -r '.needs_healing')

    if [[ "$needs_healing" != "true" ]]; then
        jq -n \
            --arg message "No healing needed - system is healthy" \
            '{status: "success", message: $message}'
        return
    fi

    local recovery_actions=()
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Heal 1: Rotate logs if too large
    local log_size
    log_size=$(du -m "$LOG_FILE" 2>/dev/null | cut -f1 || echo "0")

    if [[ $log_size -gt 100 ]]; then
        log "Rotating log file (size: ${log_size}MB)"
        mv "$LOG_FILE" "${LOG_FILE}.old"
        touch "$LOG_FILE"

        recovery_actions+=('{
            "id": "rotate_logs",
            "name": "Rotate Log Files",
            "status": "success",
            "message": "Rotated log file ('"$log_size"' MB)"
        }')
    fi

    # Heal 2: Clean up old state files
    local state_file_size
    state_file_size=$(du -k "$STATE_FILE" 2>/dev/null | cut -f1 || echo "0")

    if [[ $state_file_size -gt 1000 ]]; then
        log "Cleaning up old state entries"
        jq '.health_checks = .health_checks[-100:]' "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"

        recovery_actions+=('{
            "id": "cleanup_state",
            "name": "Clean Up State",
            "status": "success",
            "message": "Cleaned up old state entries"
        }')
    fi

    # Heal 3: Clear resolved alerts
    local alert_count
    alert_count=$(jq '.active_alerts | length' "$ALERT_FILE")

    if [[ $alert_count -gt 0 ]]; then
        # Move old alerts to history
        local old_alerts
        old_alerts=$(jq '.active_alerts' "$ALERT_FILE")

        jq '.alert_history += $old_alerts | .active_alerts = []' --argjson old_alerts "$old_alerts" "$ALERT_FILE" > "${ALERT_FILE}.tmp"
        mv "${ALERT_FILE}.tmp" "$ALERT_FILE"

        recovery_actions+=('{
            "id": "clear_alerts",
            "name": "Clear Resolved Alerts",
            "status": "success",
            "message": "Cleared '"$alert_count"' resolved alerts"
        }')
    fi

    # Convert recovery actions to JSON
    local recovery_json
    recovery_json=$(printf '%s\n' "${recovery_actions[@]}" | jq -s '.')

    # Record recovery actions
    local recovery
    recovery=$(jq -n \
        --arg timestamp "$timestamp" \
        --argjson actions "$recovery_json" \
        '{
            timestamp: $timestamp,
            actions: $actions,
            action_count: ($actions | length)
        }')

    jq ".recovery_actions += [$recovery]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Update metrics
    if [[ ${#recovery_actions[@]} -gt 0 ]]; then
        jq ".metrics.successful_recoveries += 1" "$STATE_FILE" > "${STATE_FILE}.tmp"
        mv "${STATE_FILE}.tmp" "$STATE_FILE"
    fi

    log "Self-healing complete: ${#recovery_actions[@]} actions taken"

    # Output result
    jq -n \
        --arg timestamp "$timestamp" \
        --argjson actions "$recovery_json" \
        --argjson action_count "${#recovery_actions[@]}" \
        '{
            timestamp: $timestamp,
            status: "success",
            actions_performed: $action_count,
            actions: $actions,
            message: "Self-healing complete"
        }'
}

# Monitor system health continuously
monitor() {
    init_state
    local interval="${1:-300}"  # Default 5 minutes

    log "Starting health monitoring (interval: ${interval}s)"

    while true; do
        local health_result
        health_result=$(check)

        local status
        status=$(echo "$health_result" | jq -r '.overall_status')

        if [[ "$status" == "critical" ]]; then
            log "Critical status detected, triggering self-healing"
            heal
        fi

        log "Monitoring cycle complete, next check in ${interval}s"
        sleep "$interval"
    done
}

# Get metrics
metrics() {
    init_state

    jq '.metrics' "$STATE_FILE"
}

# Get alerts
alerts() {
    init_state

    jq '.active_alerts' "$ALERT_FILE"
}

# Get history
history() {
    init_state

    jq '{
        health_checks: .health_checks[-10:],
        recovery_actions: .recovery_actions[-10:]
    }' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Self-healing state initialized"
        ;;
    check)
        check
        ;;
    heal)
        heal
        ;;
    monitor)
        monitor "${2:-300}"
        ;;
    metrics)
        metrics
        ;;
    alerts)
        alerts
        ;;
    history)
        history
        ;;
    help|*)
        cat <<EOF
Self-Healing - System Health Monitoring and Recovery

Usage:
  $0 check                              Perform health check
  $0 heal                               Trigger self-healing
  $0 monitor [interval]                 Start continuous monitoring
  $0 metrics                            Get health metrics
  $0 alerts                             Get active alerts
  $0 history                            Get health and recovery history

Health Checks:
  disk_space           - File system space usage
  memory               - Memory availability
  log_size             - Log file size
  state_integrity      - State file integrity
  error_rate           - Recent error rate in logs

Recovery Actions:
  rotate_logs          - Rotate large log files
  cleanup_state        - Clean up old state entries
  clear_alerts         - Clear resolved alerts

Status Levels:
  healthy              - All checks passing
  warning              - Some checks degraded
  critical             - Critical issues detected

Examples:
  $0 check
  $0 heal
  $0 monitor 60
  $0 metrics
EOF
        ;;
esac
