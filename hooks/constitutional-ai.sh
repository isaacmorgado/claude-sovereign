#!/bin/bash
# Constitutional AI - Ethical and Quality Validation
# Critiques and revises outputs against constitutional principles
# Usage: constitutional-ai.sh critique <output> [principles]
#        constitutional-ai.sh revise <output> <critique_json>

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/constitutional-ai.log"
mkdir -p "$(dirname "$LOG_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Define constitutional principles
PRINCIPLES='{
    "security": {
        "name": "Security",
        "description": "No security vulnerabilities, proper authentication and authorization",
        "checks": [
            "No hardcoded credentials or secrets",
            "Proper input validation and sanitization",
            "Secure authentication and authorization",
            "Protection against common attacks (XSS, SQL injection, CSRF)",
            "Secure data storage and transmission",
            "Proper error handling without information leakage"
        ]
    },
    "quality": {
        "name": "Code Quality",
        "description": "Clean, maintainable, well-structured code",
        "checks": [
            "Follows language best practices and idioms",
            "Proper error handling and edge cases",
            "Adequate comments and documentation",
            "No code duplication",
            "Consistent naming conventions",
            "Modular and testable design",
            "No magic numbers or hardcoded values"
        ]
    },
    "testing": {
        "name": "Testing",
        "description": "Comprehensive test coverage and validation",
        "checks": [
            "Unit tests for core functionality",
            "Integration tests for component interactions",
            "Edge case testing",
            "Error condition testing",
            "Performance and load testing considerations",
            "Test data covers realistic scenarios"
        ]
    },
    "error_handling": {
        "name": "Error Handling",
        "description": "Robust error handling and recovery",
        "checks": [
            "Graceful error handling",
            "Meaningful error messages",
            "Proper error propagation",
            "Logging of errors for debugging",
            "Recovery mechanisms for transient failures",
            "No silent failures"
        ]
    },
    "compatibility": {
        "name": "Compatibility",
        "description": "Works across environments and versions",
        "checks": [
            "Cross-platform compatibility",
            "Version compatibility considerations",
            "Environment variable configuration",
            "Graceful degradation for unsupported features",
            "No deprecated APIs used"
        ]
    },
    "documentation": {
        "name": "Documentation",
        "description": "Clear and comprehensive documentation",
        "checks": [
            "API documentation complete",
            "Usage examples provided",
            "Clear parameter descriptions",
            "Return value documentation",
            "Error conditions documented",
            "Setup and configuration instructions"
        ]
    },
    "simplicity": {
        "name": "Simplicity",
        "description": "Simple, straightforward solutions",
        "checks": [
            "No unnecessary complexity",
            "Clear and readable code",
            "Minimal dependencies",
            "Straightforward implementation approach",
            "No over-engineering",
            "Easy to understand and maintain"
        ]
    },
    "no_data_loss": {
        "name": "No Data Loss",
        "description": "Preserves all existing data and state",
        "checks": [
            "No destructive operations without backup",
            "Data migration handled properly",
            "State preservation during changes",
            "Rollback capability available",
            "No accidental data deletion",
            "Transaction safety for multi-step operations"
        ]
    }
}'

# Critique output against principles
critique() {
    local output="$1"
    local principles="${2:-all}"

    log "Critiquing output against principles: $principles"

    # Parse output (could be JSON, code, or text)
    local output_text="$output"

    # Determine which principles to check
    local principles_to_check="[]"
    if [[ "$principles" == "all" ]]; then
        principles_to_check='["security","quality","testing","error_handling","compatibility","documentation","simplicity","no_data_loss"]'
    else
        principles_to_check="[$principles]"
    fi

    # Run checks and collect violations
    local violations="[]"
    local overall_assessment="safe"

    for principle in security quality testing error_handling compatibility documentation simplicity no_data_loss; do
        if echo "$principles_to_check" | grep -q "\"$principle\""; then
            local principle_checks
            principle_checks=$(echo "$PRINCIPLES" | jq -r ".[\"$principle\"].checks")

            # Check for violations (simple heuristic)
            local principle_violations="[]"

            # Simple violation detection based on keywords
            for check in $principle_checks; do
                if [[ "$output_text" =~ (password|secret|key|token|credential) ]] && \
                   [[ "$principle" == "security" ]] && \
                   [[ "$check" =~ (credential|secret) ]]; then
                    principle_violations=$(echo "$principle_violations" | jq --arg msg "$check" '. + [$msg]')
                fi
                if [[ "$output_text" =~ (TODO|FIXME|hack|XXX) ]] && \
                   [[ "$principle" =~ (quality|simplicity|documentation) ]]; then
                    principle_violations=$(echo "$principle_violations" | jq --arg msg "$check" '. + [$msg]')
                fi
                if [[ "$output_text" =~ (eval|exec|system|shell_exec) ]] && \
                   [[ "$principle" == "security" ]]; then
                    principle_violations=$(echo "$principle_violations" | jq --arg msg "$check" '. + [$msg]')
                fi
                if [[ "$output_text" =~ (catch|error|exception) ]] && \
                   [[ "$principle" == "error_handling" ]]; then
                    principle_violations=$(echo "$principle_violations" | jq --arg msg "$check" '. + [$msg]')
                fi
            done

            # Add violations if any found
            if [[ "$(echo "$principle_violations" | jq 'length')" -gt 0 ]]; then
                violations=$(echo "$violations" | jq --arg principle "$principle" --argjson v "$principle_violations" '. + [{principle: $principle, violations: $v}]')
                overall_assessment="needs_revision"
            fi
        fi
    done

    # Count total violations
    local violation_count
    violation_count=$(echo "$violations" | jq 'length')

    log "Critique complete: $violation_count violations found"

    # Output critique result
    jq -n \
        --arg assessment "$overall_assessment" \
        --argjson count "$violation_count" \
        --argjson violations "$violations" \
        '{
            overall_assessment: $assessment,
            total_violations: $count,
            violations: $violations,
            principles_checked: '"$principles_to_check"',
            recommendation: (if $count > 0 then "Revise to address violations" else "Output meets constitutional principles" end)
        }'
}

# Revise output based on critique
revise() {
    local original_output="$1"
    local critique_json="$2"

    log "Revising output based on critique"

    local violations
    violations=$(echo "$critique_json" | jq -r '.violations')

    # Generate revision suggestions
    local revision_prompt="Original Output:
$original_output

Violations Found:
$violations

Please revise the output to address all violations while maintaining the original intent.
Focus on:
1. Security: Remove any security vulnerabilities
2. Quality: Improve code structure and maintainability
3. Testing: Add proper test coverage
4. Error Handling: Add robust error handling
5. Compatibility: Ensure cross-platform compatibility
6. Documentation: Add clear documentation
7. Simplicity: Simplify complex implementations
8. No Data Loss: Ensure data preservation

Provide the revised output."

    echo "$revision_prompt"
}

# Get principles definition
principles() {
    echo "$PRINCIPLES"
}

# Validate specific principle
validate() {
    local principle="$1"
    local output="$2"

    log "Validating principle: $principle"

    local principle_checks
    principle_checks=$(echo "$PRINCIPLES" | jq -r ".[\"$principle\"].checks")

    # Run validation
    local passed="true"
    local failed_checks="[]"

    for check in $principle_checks; do
        # Simple validation (in production, would use more sophisticated analysis)
        if [[ ! "$output" =~ (TODO|FIXME|hack|XXX|eval|exec) ]]; then
            failed_checks=$(echo "$failed_checks" | jq --arg msg "$check" '. + [$msg]')
            passed="false"
        fi
    done

    log "Validation result: passed=$passed"

    jq -n \
        --arg principle "$principle" \
        --arg passed "$passed" \
        --argjson failed "$failed_checks" \
        '{
            principle: $principle,
            passed: ($passed == "true"),
            failed_checks: $failed,
            checks_performed: '"$principle_checks"'
        }'
}

# Main CLI
case "${1:-help}" in
    critique)
        critique "${2:-output}" "${3:-all}"
        ;;
    revise)
        revise "${2:-output}" "${3:-critique_json}"
        ;;
    principles)
        principles
        ;;
    validate)
        validate "${2:-principle}" "${3:-output}"
        ;;
    help|*)
        cat <<EOF
Constitutional AI - Ethical and Quality Validation

Usage:
  $0 critique <output> [principles]   Critique output against principles
  $0 revise <output> <critique_json>   Revise output based on critique
  $0 principles                          List all constitutional principles
  $0 validate <principle> <output>      Validate specific principle

Principles:
  security         - No security vulnerabilities, proper auth
  quality          - Clean, maintainable, well-structured code
  testing          - Comprehensive test coverage and validation
  error_handling   - Robust error handling and recovery
  compatibility     - Works across environments and versions
  documentation     - Clear and comprehensive documentation
  simplicity       - Simple, straightforward solutions
  no_data_loss     - Preserves all existing data and state

Examples:
  $0 critique "code here" "security,quality"
  $0 revise "original code" '{"violations": [...]}'
  $0 principles
  $0 validate "security" "code with secrets"
EOF
        ;;
esac
