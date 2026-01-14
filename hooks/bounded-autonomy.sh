#!/bin/bash
# Bounded Autonomy - Safety Checks and User Approval
# Integrates with Approvals, Checker, Escalator, Prohibitions modules
# Usage: bounded-autonomy.sh check <action> <context>

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.claude/logs/bounded-autonomy.log"
STATE_FILE="${HOME}/.claude/bounded-autonomy-state.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize bounded autonomy state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "approvals": {
        "pending": [],
        "approved": [],
        "rejected": []
    },
    "prohibitions": {
        "force_push_main": true,
        "bypass_security": true,
        "expose_secrets": true,
        "delete_production_data": true,
        "deploy_production": true
    },
    "thresholds": {
        "approval_required_below": 0.7,
        "high_risk_threshold": 0.8
    }
}
EOF
    fi
}

# Check if action is allowed
check() {
    local action="$1"
    local context="${2:-}"

    init_state
    log "Checking bounded autonomy for: $action"

    local allowed="true"
    local requires_approval="false"
    local category="safe"
    local reason=""

    # Check prohibitions first
    local prohibitions
    prohibitions=$(jq -r '.prohibitions' "$STATE_FILE")

    # Check for prohibited actions
    if [[ "$action" =~ (force.*push.*main|force.*push.*master) ]] && \
       [[ "$(echo "$prohibitions" | jq -r '.force_push_main')" == "true" ]]; then
        allowed="false"
        category="prohibited"
        reason="Force pushing to main/master branch is prohibited"
    elif [[ "$action" =~ (--no-verify|--skip.*check) ]] && \
         [[ "$(echo "$prohibitions" | jq -r '.bypass_security')" == "true" ]]; then
        allowed="false"
        category="prohibited"
        reason="Bypassing security checks is prohibited"
    elif [[ "$action" =~ (secret|password|key|token|credential) ]] && \
         [[ "$(echo "$prohibitions" | jq -r '.expose_secrets')" == "true" ]]; then
        allowed="false"
        category="prohibited"
        reason="Exposing secrets/credentials is prohibited"
    elif [[ "$action" =~ (delete.*production|drop.*production|truncate.*production) ]] && \
         [[ "$(echo "$prohibitions" | jq -r '.delete_production_data')" == "true" ]]; then
        allowed="false"
        category="prohibited"
        reason="Deleting production data is prohibited"
    elif [[ "$action" =~ (deploy.*production|release.*production) ]] && \
         [[ "$(echo "$prohibitions" | jq -r '.deploy_production')" == "true" ]]; then
        allowed="false"
        category="prohibited"
        reason="Deploying to production is prohibited"
    fi

    # Check for high-risk actions that require approval
    local risk_score=0.0
    local high_risk_threshold
    high_risk_threshold=$(jq -r '.thresholds.high_risk_threshold' "$STATE_FILE")

    # Analyze action for risk factors
    [[ "$action" =~ (delete|remove|drop|truncate) ]] && risk_score=$((risk_score + 30))
    [[ "$action" =~ (git.*push|git.*commit) ]] && risk_score=$((risk_score + 20))
    [[ "$action" =~ (database|db|sql|migration) ]] && risk_score=$((risk_score + 40))
    [[ "$action" =~ (api|endpoint|route|service) ]] && risk_score=$((risk_score + 25))
    [[ "$action" =~ (auth|authentication|permission|role) ]] && risk_score=$((risk_score + 35))
    [[ "$action" =~ (payment|billing|stripe|transaction) ]] && risk_score=$((risk_score + 45))
    [[ "$action" =~ (production|prod|live) ]] && risk_score=$((risk_score + 30))

    # Normalize risk score to 0-1
    local normalized_risk
    normalized_risk=$(echo "scale=2; $risk_score / 100" | bc -l 2>/dev/null || echo "0.5")

    # Check if approval required
    local approval_threshold
    approval_threshold=$(jq -r '.thresholds.approval_required_below' "$STATE_FILE")

    if [[ "$allowed" == "true" ]] && (( $(echo "$normalized_risk < $approval_threshold" | bc -l 2>/dev/null || echo "0") )); then
        requires_approval="true"
        category="requires_approval"
        reason="Confidence below threshold (${normalized_risk} < ${approval_threshold})"
    fi

    log "Check result: allowed=$allowed, requires_approval=$requires_approval, category=$category"

    # Output JSON result
    jq -n \
        --arg allowed "$allowed" \
        --arg requires_approval "$requires_approval" \
        --arg category "$category" \
        --arg reason "$reason" \
        --argjson risk "$normalized_risk" \
        '{
            allowed: ($allowed == "true"),
            requires_approval: ($requires_approval == "true"),
            category: $category,
            reason: $reason,
            risk_score: $risk
        }'
}

# Escalate action for user approval
escalate() {
    local action="$1"
    local reason="${2:-}"
    local context="${3:-}"

    log "Escalating action for approval: $action"

    # Add to pending approvals
    local temp_file
    temp_file=$(mktemp)

    local approval_id="apr_$(date +%s%N | cut -c1-13)"

    jq --arg id "$approval_id" \
       --arg action "$action" \
       --arg reason "$reason" \
       --arg context "$context" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '.approvals.pending += [{
           id: $id,
           action: $action,
           reason: $reason,
           context: $context,
           requested_at: $ts,
           status: "pending"
       }]' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Created approval request: $approval_id"

    # Output escalation details
    jq -n \
        --arg id "$approval_id" \
        --arg action "$action" \
        --arg reason "$reason" \
        '{
            status: "escalated",
            approval_id: $id,
            action: $action,
            reason: $reason,
            message: "Action requires user approval before proceeding"
        }'
}

# Approve a pending action
approve() {
    local approval_id="$1"

    log "Approving action: $approval_id"

    local temp_file
    temp_file=$(mktemp)

    # Move from pending to approved
    jq --arg id "$approval_id" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       (.approvals.pending |= map(select(.id != $id))) |
       (.approvals.approved += (.approvals.pending | map(select(.id == $id)) | .[] | {
           status: "approved",
           approved_at: $ts
       })) |
       (.approvals.pending |= map(select(.id != $id)))
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Action approved: $approval_id"

    echo '{"status": "approved", "approval_id": "'"$approval_id"'"}'
}

# Reject a pending action
reject() {
    local approval_id="$1"
    local reason="${2:-}"

    log "Rejecting action: $approval_id"

    local temp_file
    temp_file=$(mktemp)

    # Move from pending to rejected
    jq --arg id "$approval_id" \
       --arg reason "$reason" \
       --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '
       (.approvals.pending |= map(select(.id != $id))) |
       (.approvals.rejected += (.approvals.pending | map(select(.id == $id)) | .[] | {
           status: "rejected",
           rejected_at: $ts,
           rejection_reason: $reason
       })) |
       (.approvals.pending |= map(select(.id != $id)))
       ' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Action rejected: $approval_id"

    echo '{"status": "rejected", "approval_id": "'"$approval_id"'"}'
}

# List pending approvals
list_pending() {
    init_state

    jq '.approvals.pending' "$STATE_FILE"
}

# Get bounded autonomy status
status() {
    init_state

    jq '{
        prohibitions: .prohibitions,
        thresholds: .thresholds,
        pending_approvals: (.approvals.pending | length),
        recent_approvals: (.approvals.approved | sort_by(.approved_at) | reverse | .[0:5])
    }' "$STATE_FILE"
}

# Configure thresholds
configure() {
    local key="$1"
    local value="$2"

    init_state

    local temp_file
    temp_file=$(mktemp)

    jq --arg key "$key" \
       --argjson value "$value" \
       '.thresholds[$key] = $value' \
       "$STATE_FILE" > "${temp_file}.tmp" && mv "${temp_file}.tmp" "$STATE_FILE"

    log "Updated threshold $key to $value"

    echo '{"status": "configured", "key": "'"$key"'", "value": '"$value"'}'
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Bounded autonomy state initialized"
        ;;
    check)
        check "${2:-action}" "${3:-}"
        ;;
    escalate)
        escalate "${2:-action}" "${3:-reason}" "${4:-}"
        ;;
    approve)
        approve "${2:-approval_id}"
        ;;
    reject)
        reject "${2:-approval_id}" "${3:-reason}"
        ;;
    list-pending)
        list_pending
        ;;
    status)
        status
        ;;
    configure)
        configure "${2:-key}" "${3:-value}"
        ;;
    help|*)
        cat <<EOF
Bounded Autonomy - Safety Checks and User Approval

Usage:
  $0 init                              Initialize bounded autonomy state
  $0 check <action> [context]          Check if action is allowed
  $0 escalate <action> <reason> [context]  Escalate for user approval
  $0 approve <approval_id>               Approve a pending action
  $0 reject <approval_id> [reason]         Reject a pending action
  $0 list-pending                       List pending approvals
  $0 status                             Show bounded autonomy status
  $0 configure <key> <value>            Configure thresholds

Prohibited Actions (always blocked):
  - Force push to main/master branch
  - Bypass security checks (--no-verify)
  - Expose secrets/credentials
  - Delete production data
  - Deploy to production

Approval Thresholds:
  - approval_required_below: 0.7 (actions below 70% confidence need approval)
  - high_risk_threshold: 0.8 (high-risk actions need approval)

Examples:
  $0 check "git push origin main"
  $0 escalate "deploy to production" "High risk action"
  $0 list-pending
  $0 approve apr_1234567890
  $0 configure approval_required_below 0.8
EOF
        ;;
esac
