#!/bin/bash
# Constitutional AI - Ethical guardrails and principles
# Based on: LangChain Constitutional AI, Anthropic Constitutional AI papers
# Ensures agent behavior aligns with defined principles

set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
LOG_FILE="${CLAUDE_DIR}/constitutional-ai.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Define constitutional principles
get_principles() {
    cat << 'EOF'
{
    "principles": [
        {
            "name": "code_quality",
            "critique": "Identify ways the code could be improved for readability, maintainability, or performance",
            "revision": "Revise the code to be more readable, maintainable, and performant"
        },
        {
            "name": "security_first",
            "critique": "Identify potential security vulnerabilities such as XSS, SQL injection, command injection, or exposed secrets",
            "revision": "Revise to eliminate security vulnerabilities and follow security best practices"
        },
        {
            "name": "test_coverage",
            "critique": "Identify missing test cases, edge cases not covered, or inadequate assertions",
            "revision": "Revise to include comprehensive test coverage for all scenarios"
        },
        {
            "name": "error_handling",
            "critique": "Identify missing error handling, uncaught exceptions, or inadequate error messages",
            "revision": "Revise to include proper error handling with clear, actionable error messages"
        },
        {
            "name": "backwards_compatibility",
            "critique": "Identify changes that could break existing functionality or APIs",
            "revision": "Revise to maintain backwards compatibility or clearly document breaking changes"
        },
        {
            "name": "documentation",
            "critique": "Identify missing documentation, unclear explanations, or outdated comments",
            "revision": "Revise to include clear, accurate documentation"
        },
        {
            "name": "simplicity",
            "critique": "Identify over-engineering, unnecessary complexity, or premature optimization",
            "revision": "Revise to use the simplest approach that meets requirements"
        },
        {
            "name": "no_data_loss",
            "critique": "Identify operations that could result in data loss or corruption",
            "revision": "Revise to protect against data loss with appropriate safeguards"
        }
    ]
}
EOF
}

# Rule-based safety checks for each principle
check_security_first() {
    local output="$1"
    local violations=()

    # Check for SQL injection patterns
    if echo "$output" | grep -qE "execute\(|query\(.*\$|SELECT.*\+|INSERT.*\+|UPDATE.*\+|DELETE.*\+"; then
        violations+=("Potential SQL injection: found string concatenation in SQL queries")
    fi

    # Check for command injection patterns
    if echo "$output" | grep -qE 'exec\(|system\(|shell_exec\(|eval\(|`.*\$|os\.system|subprocess\.call'; then
        violations+=("Potential command injection: found unsafe command execution")
    fi

    # Check for exposed secrets
    if echo "$output" | grep -qiE "(password|secret|api_key|token|private_key).*=.*['\"].*['\"]"; then
        violations+=("Potential exposed secrets: hardcoded credentials detected")
    fi

    # Check for XSS patterns
    if echo "$output" | grep -qE "innerHTML|dangerouslySetInnerHTML|document\.write"; then
        violations+=("Potential XSS: unsafe DOM manipulation detected")
    fi

    # Print each violation on a new line
    if [[ ${#violations[@]} -gt 0 ]]; then
        printf '%s\n' "${violations[@]}"
    fi
}

check_no_data_loss() {
    local output="$1"
    local violations=()

    # Check for deletion without confirmation
    if echo "$output" | grep -qiE "rm -rf|DROP TABLE|DELETE FROM|TRUNCATE|unlink|remove_all"; then
        if ! echo "$output" | grep -qiE "confirm|prompt|--force|yes/no|are you sure"; then
            violations+=("Data deletion without user confirmation detected")
        fi
    fi

    # Check for overwriting without backup
    if echo "$output" | grep -qE ">\s*['\"]|write\(|WriteFile"; then
        if ! echo "$output" | grep -qiE "backup|copy|snapshot|--backup"; then
            violations+=("File overwrite without backup detected")
        fi
    fi

    # Print each violation on a new line
    if [[ ${#violations[@]} -gt 0 ]]; then
        printf '%s\n' "${violations[@]}"
    fi
}

check_error_handling() {
    local output="$1"
    local violations=()

    # Check for try/catch in code blocks
    if echo "$output" | grep -qE "function |def |async "; then
        if ! echo "$output" | grep -qE "try\s*{|try:|except|catch"; then
            violations+=("Missing error handling in function definitions")
        fi
    fi

    # Check for error swallowing
    if echo "$output" | grep -qE "catch.*{[\s]*}|except:[\s]*pass"; then
        violations+=("Empty catch/except blocks found (error swallowing)")
    fi

    # Print each violation on a new line
    if [[ ${#violations[@]} -gt 0 ]]; then
        printf '%s\n' "${violations[@]}"
    fi
}

check_test_coverage() {
    local output="$1"
    local violations=()

    # Check if it's code but no tests mentioned
    if echo "$output" | grep -qE "function |class |def |export "; then
        if ! echo "$output" | grep -qiE "test|spec|describe|it\(|assert|expect"; then
            violations+=("Code without corresponding tests")
        fi
    fi

    # Print each violation on a new line
    if [[ ${#violations[@]} -gt 0 ]]; then
        printf '%s\n' "${violations[@]}"
    fi
}

check_code_quality() {
    local output="$1"
    local violations=()

    # Check for TODO/FIXME/HACK comments
    if echo "$output" | grep -qiE "TODO|FIXME|HACK|XXX"; then
        violations+=("Unresolved TODO/FIXME comments in production code")
    fi

    # Check for very long lines (>120 chars)
    local long_lines
    long_lines=$(echo "$output" | awk 'length > 120 {count++} END {print count+0}')
    if [[ "$long_lines" -gt 3 ]]; then
        violations+=("Multiple lines exceed 120 characters (readability issue)")
    fi

    # Print each violation on a new line
    if [[ ${#violations[@]} -gt 0 ]]; then
        printf '%s\n' "${violations[@]}"
    fi
}

# Critique output against principles
critique_output() {
    local output="$1"
    local principles="${2:-all}"

    log "Critiquing output against principles: $principles"

    local all_violations=()
    local principles_violated=()

    # Run rule-based checks
    if [[ "$principles" == "all" ]] || [[ "$principles" == "security_first" ]]; then
        local sec_violations
        sec_violations=$(check_security_first "$output")
        if [[ -n "$sec_violations" ]]; then
            # Read each line as a separate violation
            while IFS= read -r violation; do
                all_violations+=("$violation")
            done <<< "$sec_violations"
            principles_violated+=("security_first")
        fi
    fi

    if [[ "$principles" == "all" ]] || [[ "$principles" == "no_data_loss" ]]; then
        local data_violations
        data_violations=$(check_no_data_loss "$output")
        if [[ -n "$data_violations" ]]; then
            while IFS= read -r violation; do
                all_violations+=("$violation")
            done <<< "$data_violations"
            principles_violated+=("no_data_loss")
        fi
    fi

    if [[ "$principles" == "all" ]] || [[ "$principles" == "error_handling" ]]; then
        local error_violations
        error_violations=$(check_error_handling "$output")
        if [[ -n "$error_violations" ]]; then
            while IFS= read -r violation; do
                all_violations+=("$violation")
            done <<< "$error_violations"
            principles_violated+=("error_handling")
        fi
    fi

    if [[ "$principles" == "all" ]] || [[ "$principles" == "test_coverage" ]]; then
        local test_violations
        test_violations=$(check_test_coverage "$output")
        if [[ -n "$test_violations" ]]; then
            while IFS= read -r violation; do
                all_violations+=("$violation")
            done <<< "$test_violations"
            principles_violated+=("test_coverage")
        fi
    fi

    if [[ "$principles" == "all" ]] || [[ "$principles" == "code_quality" ]]; then
        local quality_violations
        quality_violations=$(check_code_quality "$output")
        if [[ -n "$quality_violations" ]]; then
            while IFS= read -r violation; do
                all_violations+=("$violation")
            done <<< "$quality_violations"
            principles_violated+=("code_quality")
        fi
    fi

    # Determine overall assessment
    local assessment="safe"
    local violation_count=${#all_violations[@]}

    if [[ $violation_count -gt 0 ]]; then
        # Check if any high-severity violations exist
        if [[ " ${principles_violated[@]} " =~ " security_first " ]] || [[ " ${principles_violated[@]} " =~ " no_data_loss " ]]; then
            assessment="needs_revision"
        else
            assessment="needs_revision"
        fi
    fi

    # Build violations array as JSON
    local violations_json="[]"
    if [[ $violation_count -gt 0 ]]; then
        violations_json=$(printf '%s\n' "${all_violations[@]}" | jq -R . | jq -s .)
    fi

    # Build principles_violated array as JSON
    local principles_json="[]"
    if [[ ${#principles_violated[@]} -gt 0 ]]; then
        principles_json=$(printf '%s\n' "${principles_violated[@]}" | jq -R . | jq -s .)
    fi

    # Return actual results
    cat << EOF
{
    "overall_assessment": "$assessment",
    "violations": $violations_json,
    "principles_violated": $principles_json,
    "details": "Found $violation_count violations across ${#principles_violated[@]} principles"
}
EOF
}

# Apply automatic revisions based on critique
apply_revisions() {
    local output="$1"
    local critique_json="$2"

    log "Applying automatic revisions"

    local revised="$output"
    local changes_made=()
    local still_has_issues=false

    # Parse violations
    local violations
    violations=$(echo "$critique_json" | jq -r '.violations[]' 2>/dev/null || echo "")

    if [[ -z "$violations" ]]; then
        # No violations, return original
        cat << EOF
{
    "revised_content": $(echo "$output" | jq -Rs .),
    "changes_made": [],
    "still_has_issues": false
}
EOF
        return
    fi

    # Apply automatic fixes based on violation patterns
    while IFS= read -r violation; do
        case "$violation" in
            *"SQL injection"*)
                # Add warning comment about SQL injection
                revised=$(echo "$revised" | sed '1i\
# WARNING: SQL injection risk detected - use parameterized queries')
                changes_made+=("Added SQL injection warning comment")
                still_has_issues=true  # Can't auto-fix, needs manual intervention
                ;;
            *"command injection"*)
                # Add warning comment about command injection
                revised=$(echo "$revised" | sed '1i\
# WARNING: Command injection risk detected - validate inputs')
                changes_made+=("Added command injection warning comment")
                still_has_issues=true
                ;;
            *"exposed secrets"*)
                # Replace hardcoded secrets with environment variables
                if echo "$revised" | grep -qE "password.*=.*['\"]"; then
                    revised=$(echo "$revised" | sed -E "s/(password|secret|api_key|token).*=.*['\"].*['\"]/\1 = process.env.\U\1\E || ''  # SECURITY: Use environment variable/g")
                    changes_made+=("Replaced hardcoded secrets with environment variables")
                fi
                ;;
            *"XSS"*)
                # Add warning comment about XSS
                revised=$(echo "$revised" | sed '1i\
# WARNING: XSS risk detected - sanitize user inputs')
                changes_made+=("Added XSS warning comment")
                still_has_issues=true
                ;;
            *"deletion without user confirmation"*)
                # Add confirmation check before deletion
                if echo "$revised" | grep -qE "rm -rf|DROP TABLE|DELETE FROM"; then
                    revised=$(echo "$revised" | sed '1i\
# TODO: Add user confirmation before deletion')
                    changes_made+=("Added TODO for user confirmation")
                    still_has_issues=true
                fi
                ;;
            *"overwrite without backup"*)
                # Add backup suggestion
                revised=$(echo "$revised" | sed '1i\
# TODO: Create backup before overwriting files')
                changes_made+=("Added TODO for backup creation")
                still_has_issues=true
                ;;
            *"Missing error handling"*)
                # Add comment about error handling
                revised=$(echo "$revised" | sed '1i\
# TODO: Add try/catch error handling')
                changes_made+=("Added TODO for error handling")
                still_has_issues=true
                ;;
            *"Empty catch"*)
                # Add comment in empty catch blocks
                revised=$(echo "$revised" | sed -E "s/catch.*\{[\s]*\}/catch (error) { \/\/ TODO: Handle error properly }/g")
                changes_made+=("Added TODO in empty catch blocks")
                still_has_issues=true
                ;;
            *"Code without corresponding tests"*)
                # Add comment about tests
                revised=$(echo "$revised" | sed '1i\
# TODO: Add unit tests for this code')
                changes_made+=("Added TODO for unit tests")
                still_has_issues=true
                ;;
            *"TODO/FIXME"*)
                # Can't auto-fix, but note it
                changes_made+=("Detected unresolved TODO/FIXME comments")
                still_has_issues=true
                ;;
            *"exceed 120 characters"*)
                # Note the issue
                changes_made+=("Detected long lines (manual formatting needed)")
                still_has_issues=true
                ;;
        esac
    done <<< "$violations"

    # Build changes_made array as JSON
    local changes_json="[]"
    if [[ ${#changes_made[@]} -gt 0 ]]; then
        changes_json=$(printf '%s\n' "${changes_made[@]}" | jq -R . | jq -s .)
    fi

    # Return results
    cat << EOF
{
    "revised_content": $(echo "$revised" | jq -Rs .),
    "changes_made": $changes_json,
    "still_has_issues": $still_has_issues
}
EOF
}

case "${1:-help}" in
    principles)
        get_principles
        ;;
    critique)
        critique_output "${2:-output}" "${3:-all}"
        ;;
    revise)
        apply_revisions "${2:-output}" "${3:-{}}"
        ;;
    help|*)
        echo "Constitutional AI - Ethical Guardrails"
        echo "Usage: $0 <command> [args]"
        echo "  principles                  - List all principles"
        echo "  critique <output> [principle] - Critique against principles (returns assessment)"
        echo "  revise <output> <critique>    - Apply automatic revisions (returns revised content)"
        ;;
esac
