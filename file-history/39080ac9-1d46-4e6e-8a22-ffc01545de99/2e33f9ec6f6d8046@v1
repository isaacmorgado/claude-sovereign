#!/bin/bash
# Validation Gate - Pre-execution checks and safety validation
# Based on patterns from: oracle validateBeforeExecute, langchain guardrails, codegen safety checks

set -uo pipefail

GATE_DIR="${HOME}/.claude/gates"
GATE_RESULTS="$GATE_DIR/results.json"
LOG_FILE="${HOME}/.claude/validation-gate.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_gates() {
    mkdir -p "$GATE_DIR"
    if [[ ! -f "$GATE_RESULTS" ]]; then
        echo '{"checks":[]}' > "$GATE_RESULTS"
    fi
}

# =============================================================================
# PRE-EXECUTION VALIDATION
# =============================================================================

# Validate before executing a command
validate_command() {
    local command="$1"
    local context="${2:-}"

    local issues=()
    local warnings=()

    # Check for dangerous patterns
    if [[ "$command" =~ rm[[:space:]]+-rf[[:space:]]+(\/|~|\$HOME|\*) ]]; then
        issues+=("DANGEROUS: Recursive delete on critical path detected")
    fi

    if [[ "$command" =~ sudo[[:space:]] ]]; then
        warnings+=("Command requires sudo privileges")
    fi

    if [[ "$command" =~ \>\>[[:space:]]*(\/etc|\/usr|\/bin|\/sbin) ]]; then
        issues+=("DANGEROUS: Writing to system directory")
    fi

    if [[ "$command" =~ chmod[[:space:]]+(777|666) ]]; then
        warnings+=("Insecure permissions detected")
    fi

    if [[ "$command" =~ curl.*\|.*sh ]] || [[ "$command" =~ wget.*\|.*sh ]]; then
        issues+=("DANGEROUS: Pipe to shell detected")
    fi

    if [[ "$command" =~ eval[[:space:]] ]]; then
        warnings+=("eval usage detected - verify input is trusted")
    fi

    if [[ "$command" =~ \$\( ]] && [[ "$command" =~ rm|del|format ]]; then
        warnings+=("Command substitution with destructive command")
    fi

    # Output results
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "BLOCKED"
        for issue in "${issues[@]}"; do
            echo "  ERROR: $issue"
        done
        log "BLOCKED command: $command"
        return 1
    elif [[ ${#warnings[@]} -gt 0 ]]; then
        echo "WARNING"
        for warning in "${warnings[@]}"; do
            echo "  WARN: $warning"
        done
        log "WARNING for command: $command"
        return 0
    else
        echo "PASS"
        return 0
    fi
}

# Validate file operation
validate_file_op() {
    local operation="$1"  # read, write, delete, execute
    local path="$2"

    local issues=()
    local warnings=()

    # Resolve path
    local resolved_path
    resolved_path=$(realpath -m "$path" 2>/dev/null || echo "$path")

    # Check protected paths
    local protected_paths=(
        "/etc/passwd" "/etc/shadow" "/etc/sudoers"
        "/boot" "/proc" "/sys"
        "$HOME/.ssh/id_rsa" "$HOME/.ssh/id_ed25519"
        "$HOME/.gnupg"
    )

    for protected in "${protected_paths[@]}"; do
        if [[ "$resolved_path" == "$protected"* ]]; then
            if [[ "$operation" != "read" ]]; then
                issues+=("PROTECTED: Cannot $operation protected path: $protected")
            else
                warnings+=("Reading from sensitive path: $protected")
            fi
        fi
    done

    # Check for dotfile modifications
    if [[ "$operation" == "write" || "$operation" == "delete" ]]; then
        if [[ "$resolved_path" == "$HOME/."* ]]; then
            warnings+=("Modifying dotfile: $resolved_path")
        fi
    fi

    # Check file existence for reads
    if [[ "$operation" == "read" ]] && [[ ! -e "$path" ]]; then
        issues+=("File does not exist: $path")
    fi

    # Check directory traversal
    if [[ "$path" =~ \.\. ]]; then
        warnings+=("Path contains directory traversal: $path")
    fi

    # Output results
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "BLOCKED"
        for issue in "${issues[@]}"; do
            echo "  ERROR: $issue"
        done
        return 1
    elif [[ ${#warnings[@]} -gt 0 ]]; then
        echo "WARNING"
        for warning in "${warnings[@]}"; do
            echo "  WARN: $warning"
        done
        return 0
    else
        echo "PASS"
        return 0
    fi
}

# =============================================================================
# CODE VALIDATION
# =============================================================================

# Validate code before writing
validate_code() {
    local code="$1"
    local language="${2:-auto}"

    local issues=()
    local warnings=()

    # Auto-detect language if needed
    if [[ "$language" == "auto" ]]; then
        if [[ "$code" =~ ^import[[:space:]] ]] || [[ "$code" =~ ^from[[:space:]] ]]; then
            language="python"
        elif [[ "$code" =~ ^const[[:space:]] ]] || [[ "$code" =~ ^import[[:space:]]\{ ]]; then
            language="javascript"
        elif [[ "$code" =~ ^package[[:space:]] ]]; then
            language="go"
        fi
    fi

    # Common security patterns
    if [[ "$code" =~ eval\( ]]; then
        warnings+=("eval() usage - potential code injection")
    fi

    if [[ "$code" =~ exec\( ]]; then
        warnings+=("exec() usage - verify input sanitization")
    fi

    # SQL injection patterns
    if [[ "$code" =~ \+[[:space:]]*[\"\'](SELECT|INSERT|UPDATE|DELETE) ]]; then
        issues+=("Potential SQL injection: string concatenation in query")
    fi

    # Hardcoded credentials
    if [[ "$code" =~ password[[:space:]]*=[[:space:]]*[\"\'][^\"\'\$] ]]; then
        issues+=("Hardcoded password detected")
    fi

    if [[ "$code" =~ (api_key|apikey|secret)[[:space:]]*=[[:space:]]*[\"\'][a-zA-Z0-9] ]]; then
        issues+=("Hardcoded API key/secret detected")
    fi

    # Language-specific checks
    case "$language" in
        python)
            if [[ "$code" =~ subprocess\.call.*shell=True ]]; then
                warnings+=("subprocess with shell=True - potential command injection")
            fi
            if [[ "$code" =~ pickle\.load ]]; then
                warnings+=("pickle.load - potential arbitrary code execution")
            fi
            ;;
        javascript|typescript)
            if [[ "$code" =~ innerHTML[[:space:]]*= ]]; then
                warnings+=("innerHTML assignment - potential XSS")
            fi
            if [[ "$code" =~ dangerouslySetInnerHTML ]]; then
                warnings+=("dangerouslySetInnerHTML - verify content is sanitized")
            fi
            ;;
        go)
            if [[ "$code" =~ os/exec.*Command ]]; then
                warnings+=("Command execution - verify input sanitization")
            fi
            ;;
    esac

    # Output results
    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "BLOCKED"
        for issue in "${issues[@]}"; do
            echo "  ERROR: $issue"
        done
        return 1
    elif [[ ${#warnings[@]} -gt 0 ]]; then
        echo "WARNING"
        for warning in "${warnings[@]}"; do
            echo "  WARN: $warning"
        done
        return 0
    else
        echo "PASS"
        return 0
    fi
}

# =============================================================================
# GATE CHECKS
# =============================================================================

# Run all gates for an action
run_gates() {
    local action_type="$1"  # command, file, code
    local action_data="$2"
    local context="${3:-}"

    init_gates

    local gate_id
    gate_id="gate_$(date +%s%N | cut -c1-13)"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local result
    local status="pass"
    local details=""

    case "$action_type" in
        command)
            result=$(validate_command "$action_data" "$context")
            ;;
        file)
            local operation="${context:-read}"
            result=$(validate_file_op "$operation" "$action_data")
            ;;
        code)
            local language="${context:-auto}"
            result=$(validate_code "$action_data" "$language")
            ;;
        *)
            result="PASS"
            ;;
    esac

    # Parse result
    if [[ "$result" == BLOCKED* ]]; then
        status="blocked"
        details=$(echo "$result" | tail -n +2)
    elif [[ "$result" == WARNING* ]]; then
        status="warning"
        details=$(echo "$result" | tail -n +2)
    fi

    # Record result
    local temp_file
    temp_file=$(mktemp)

    jq --arg id "$gate_id" \
       --arg type "$action_type" \
       --arg data "$action_data" \
       --arg status "$status" \
       --arg details "$details" \
       --arg ts "$timestamp" \
       '
       .checks = [{
           id: $id,
           type: $type,
           data: ($data | .[0:500]),
           status: $status,
           details: $details,
           timestamp: $ts
       }] + .checks |
       .checks = .checks[:100]
       ' "$GATE_RESULTS" > "$temp_file"

    mv "$temp_file" "$GATE_RESULTS"

    log "Gate check: $action_type -> $status"

    echo "$status"
    if [[ -n "$details" ]]; then
        echo "$details"
    fi

    [[ "$status" != "blocked" ]]
}

# Pre-flight check for a build/task
preflight_check() {
    local project_dir="${1:-.}"

    local issues=()
    local warnings=()

    # Check if in git repo
    if ! git -C "$project_dir" rev-parse --git-dir >/dev/null 2>&1; then
        warnings+=("Not in a git repository")
    else
        # Check for uncommitted changes
        if [[ -n $(git -C "$project_dir" status --porcelain 2>/dev/null) ]]; then
            warnings+=("Uncommitted changes in repository")
        fi
    fi

    # Check for required files
    local required_files=("package.json" "requirements.txt" "go.mod" "Cargo.toml" "pom.xml")
    local found_config=false

    for file in "${required_files[@]}"; do
        if [[ -f "$project_dir/$file" ]]; then
            found_config=true
            break
        fi
    done

    if [[ "$found_config" == "false" ]]; then
        warnings+=("No recognized project configuration found")
    fi

    # Check disk space
    local available_space
    available_space=$(df -k "$project_dir" | awk 'NR==2 {print $4}')
    if [[ $available_space -lt 1048576 ]]; then  # Less than 1GB
        warnings+=("Low disk space: $(( available_space / 1024 )) MB available")
    fi

    # Check for .env file (secrets exposure)
    if [[ -f "$project_dir/.env" ]]; then
        if ! grep -q "^\.env$" "$project_dir/.gitignore" 2>/dev/null; then
            issues+=(".env file exists but may not be in .gitignore")
        fi
    fi

    # Output results
    echo "=== Preflight Check ==="

    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "ISSUES:"
        for issue in "${issues[@]}"; do
            echo "  - $issue"
        done
    fi

    if [[ ${#warnings[@]} -gt 0 ]]; then
        echo "WARNINGS:"
        for warning in "${warnings[@]}"; do
            echo "  - $warning"
        done
    fi

    if [[ ${#issues[@]} -eq 0 ]] && [[ ${#warnings[@]} -eq 0 ]]; then
        echo "All checks passed"
    fi

    [[ ${#issues[@]} -eq 0 ]]
}

# =============================================================================
# GUARDRAILS
# =============================================================================

# Check resource limits
check_resources() {
    local max_memory="${1:-4096}"  # MB
    local max_cpu="${2:-80}"       # percent

    local issues=()

    # Check memory
    local used_memory
    if [[ "$(uname)" == "Darwin" ]]; then
        used_memory=$(vm_stat | awk '/Pages active/ {print $3}' | tr -d '.')
        used_memory=$((used_memory * 4096 / 1024 / 1024))  # Convert to MB
    else
        used_memory=$(free -m | awk 'NR==2 {print $3}')
    fi

    if [[ $used_memory -gt $max_memory ]]; then
        issues+=("Memory usage high: ${used_memory}MB > ${max_memory}MB limit")
    fi

    # Check CPU (simplified)
    local cpu_usage
    if [[ "$(uname)" == "Darwin" ]]; then
        cpu_usage=$(top -l 1 | grep "CPU usage" | awk '{print $3}' | tr -d '%')
    else
        cpu_usage=$(top -bn1 | grep "Cpu(s)" | awk '{print $2}' | tr -d '%')
    fi

    if [[ -n "$cpu_usage" ]] && (( $(echo "$cpu_usage > $max_cpu" | bc -l 2>/dev/null || echo 0) )); then
        issues+=("CPU usage high: ${cpu_usage}% > ${max_cpu}% limit")
    fi

    if [[ ${#issues[@]} -gt 0 ]]; then
        echo "RESOURCE_LIMIT"
        for issue in "${issues[@]}"; do
            echo "  $issue"
        done
        return 1
    fi

    echo "RESOURCES_OK"
    return 0
}

# Get gate statistics
get_stats() {
    if [[ ! -f "$GATE_RESULTS" ]]; then
        echo '{"total":0,"passed":0,"warnings":0,"blocked":0}'
        return
    fi

    jq '
        .checks | length as $total |
        [.[] | select(.status == "pass")] | length as $passed |
        [.[] | select(.status == "warning")] | length as $warnings |
        [.[] | select(.status == "blocked")] | length as $blocked |
        {
            total: $total,
            passed: $passed,
            warnings: $warnings,
            blocked: $blocked,
            passRate: (if $total > 0 then (($passed + $warnings) * 100 / $total | floor) else 100 end)
        }
    ' "$GATE_RESULTS"
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    command)
        validate_command "${2:-echo test}" "${3:-}"
        ;;
    file)
        validate_file_op "${2:-read}" "${3:-.}"
        ;;
    code)
        validate_code "${2:-print('hello')}" "${3:-auto}"
        ;;
    gate)
        run_gates "${2:-command}" "${3:-echo test}" "${4:-}"
        ;;
    preflight)
        preflight_check "${2:-.}"
        ;;
    resources)
        check_resources "${2:-4096}" "${3:-80}"
        ;;
    stats)
        get_stats
        ;;
    help|*)
        echo "Validation Gate - Pre-execution Safety Checks"
        echo ""
        echo "Usage: $0 <command> [args]"
        echo ""
        echo "Validation Commands:"
        echo "  command <cmd> [context]           - Validate shell command"
        echo "  file <operation> <path>           - Validate file operation"
        echo "    Operations: read, write, delete, execute"
        echo "  code <code> [language]            - Validate code snippet"
        echo "    Languages: python, javascript, go, auto"
        echo ""
        echo "Gate Commands:"
        echo "  gate <type> <data> [context]      - Run full gate check"
        echo "  preflight [dir]                   - Run preflight checks"
        echo "  resources [max_mem] [max_cpu]     - Check resource limits"
        echo ""
        echo "Status:"
        echo "  stats                             - Get gate statistics"
        ;;
esac
