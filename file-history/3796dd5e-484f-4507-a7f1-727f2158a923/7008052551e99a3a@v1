#!/bin/bash
# Bounded Autonomy - Safety guardrails and escalation paths
# Based on: Deloitte bounded autonomy patterns, enterprise AI governance
# Implements clear operational limits and human escalation

set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
LOG_FILE="${CLAUDE_DIR}/bounded-autonomy.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Define autonomy boundaries
get_autonomy_rules() {
    cat << 'EOF'
{
    "auto_allowed": {
        "description": "Actions that can be taken without approval",
        "actions": [
            "Read files",
            "Search code",
            "Run tests",
            "Run linters",
            "Edit files (< 100 lines changed)",
            "Add/update comments",
            "Fix linting errors",
            "Update dependencies (patch/minor versions)",
            "Create test files",
            "Fix test failures",
            "Update documentation",
            "Refactor without changing behavior (< 50 lines)"
        ],
        "limits": {
            "max_file_changes": 10,
            "max_lines_per_file": 100,
            "max_new_files": 3,
            "max_deletions": 20
        }
    },
    "requires_approval": {
        "description": "Actions requiring user confirmation",
        "actions": [
            "Architecture changes",
            "Database migrations",
            "External API integrations",
            "Security-sensitive code",
            "Large refactoring (> 100 lines)",
            "Dependency major version updates",
            "Configuration changes",
            "Delete files",
            "Modify build scripts",
            "Change CI/CD pipelines",
            "Install new dependencies"
        ],
        "escalation_triggers": [
            "Confidence < 70%",
            "High risk operation",
            "Multiple failures (> 2)",
            "Ambiguous requirements",
            "Security implications"
        ]
    },
    "prohibited": {
        "description": "Actions never allowed autonomously",
        "actions": [
            "Commit with --no-verify",
            "Force push to main/master",
            "Delete production data",
            "Expose secrets/credentials",
            "Bypass security checks",
            "Modify .git directory",
            "Change system files",
            "Deploy to production"
        ]
    }
}
EOF
}

# Check if action requires approval
check_action_autonomy() {
    local action="$1"
    local context="$2"

    log "Checking autonomy for action: $action"

    local rules
    rules=$(get_autonomy_rules)

    # Check if prohibited
    local prohibited
    prohibited=$(echo "$rules" | jq -r '.prohibited.actions[]')
    if echo "$prohibited" | grep -qi "$action"; then
        echo '{"allowed":false,"reason":"prohibited_action","requires":"user_intervention"}'
        return
    fi

    # Check if requires approval
    local requires_approval
    requires_approval=$(echo "$rules" | jq -r '.requires_approval.actions[]')
    if echo "$requires_approval" | grep -qi "$action"; then
        echo '{"allowed":false,"reason":"requires_approval","requires":"user_confirmation","escalate":true}'
        return
    fi

    # Check auto_allowed limits
    echo '{"allowed":true,"reason":"auto_allowed","limits":'"$(echo "$rules" | jq -c '.auto_allowed.limits')"'}'
}

# Generate escalation message
generate_escalation() {
    local action="$1"
    local reason="$2"
    local context="$3"

    cat << EOF
{
    "escalation": {
        "action": "$action",
        "reason": "$reason",
        "context": "$context",
        "message": "🛑 ESCALATION REQUIRED

**Action:** $action
**Reason:** $reason
**Context:** $context

This action requires your approval before I can proceed.

**Options:**
1. Approve - I'll proceed with this action
2. Modify - Suggest changes to the approach
3. Reject - I'll try a different approach

Please respond with your decision.",
        "timestamp": "$(date -u +%Y-%m-%dT%H:%M:%SZ)"
    }
}
EOF
}

case "${1:-help}" in
    check)
        check_action_autonomy "${2:-action}" "${3:-context}"
        ;;
    rules)
        get_autonomy_rules
        ;;
    escalate)
        generate_escalation "${2:-action}" "${3:-reason}" "${4:-context}"
        ;;
    help|*)
        echo "Bounded Autonomy - Safety Guardrails"
        echo "Usage: $0 <command> [args]"
        echo "  check <action> [context]  - Check if action is allowed"
        echo "  rules                     - Show autonomy rules"
        echo "  escalate <action> <reason> <context> - Generate escalation"
        ;;
esac
