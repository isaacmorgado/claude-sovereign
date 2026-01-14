#!/bin/bash
# Hypothesis Tester - Generate and Test Hypotheses
# Scientific approach to problem solving with hypothesis generation and verification
# Usage: hypothesis-tester.sh generate <problem> | test <hypothesis> <evidence>

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/hypothesis-tester.log"
STATE_FILE="${HOME}/.claude/hypothesis-tester-state.json"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$(dirname "$STATE_FILE")"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Initialize state
init_state() {
    if [[ ! -f "$STATE_FILE" ]]; then
        cat > "$STATE_FILE" << 'EOF'
{
    "hypotheses": [],
    "test_results": [],
    "patterns": {}
}
EOF
    fi
}

# Generate hypotheses for a problem
generate() {
    local problem="$1"
    local context="${2:-}"

    init_state
    log "Generating hypotheses for: $problem"

    # Parse problem to identify key elements
    local problem_lower
    problem_lower=$(echo "$problem" | tr '[:upper:]' '[:lower:]')

    # Generate hypotheses based on problem type
    local hypotheses=()

    case "$problem_lower" in
        *bug*|*error*|*issue*|*fail*|*crash*|*exception*)
            hypotheses+=('{
                "id": "h1",
                "hypothesis": "The bug is caused by incorrect state management",
                "type": "root_cause",
                "confidence": 0.7,
                "test_method": "Add logging to track state changes",
                "expected_outcome": "State transitions will show unexpected mutation"
            }')
            hypotheses+=('{
                "id": "h2",
                "hypothesis": "The bug is caused by race condition in async operations",
                "type": "timing",
                "confidence": 0.6,
                "test_method": "Add delays and observe behavior changes",
                "expected_outcome": "Bug appears/disappears with timing changes"
            }')
            hypotheses+=('{
                "id": "h3",
                "hypothesis": "The bug is caused by incorrect data type handling",
                "type": "data",
                "confidence": 0.5,
                "test_method": "Add type checking and validation",
                "expected_outcome": "Type mismatches will be found"
            }')
            ;;
        *slow*|*performance*|*latency*|*timeout*)
            hypotheses+=('{
                "id": "h1",
                "hypothesis": "Performance issue is caused by inefficient algorithm",
                "type": "algorithm",
                "confidence": 0.8,
                "test_method": "Profile and measure time complexity",
                "expected_outcome": "Algorithm complexity matches observed slowdown"
            }')
            hypotheses+=('{
                "id": "h2",
                "hypothesis": "Performance issue is caused by database query inefficiency",
                "type": "database",
                "confidence": 0.7,
                "test_method": "Analyze query plans and add indexes",
                "expected_outcome": "Query optimization improves performance"
            }')
            hypotheses+=('{
                "id": "h3",
                "hypothesis": "Performance issue is caused by memory pressure",
                "type": "memory",
                "confidence": 0.6,
                "test_method": "Monitor memory usage during operations",
                "expected_outcome": "Memory spikes correlate with slowdown"
            }')
            ;;
        *integration*|*connection*|*api*|*network*)
            hypotheses+=('{
                "id": "h1",
                "hypothesis": "Integration issue is caused by API contract mismatch",
                "type": "interface",
                "confidence": 0.7,
                "test_method": "Compare API documentation with actual implementation",
                "expected_outcome": "Differences found in request/response format"
            }')
            hypotheses+=('{
                "id": "h2",
                "hypothesis": "Integration issue is caused by authentication/authorization problem",
                "type": "security",
                "confidence": 0.6,
                "test_method": "Test with different credentials and tokens",
                "expected_outcome": "Authentication failures reveal the issue"
            }')
            ;;
        *)
            # Generic hypotheses
            hypotheses+=('{
                "id": "h1",
                "hypothesis": "The problem is caused by missing or incorrect configuration",
                "type": "configuration",
                "confidence": 0.6,
                "test_method": "Review and validate all configuration settings",
                "expected_outcome": "Configuration errors will be found"
            }')
            hypotheses+=('{
                "id": "h2",
                "hypothesis": "The problem is caused by a recent code change",
                "type": "regression",
                "confidence": 0.5,
                "test_method": "Review recent commits and test against previous version",
                "expected_outcome": "Identifying the problematic commit"
            }')
            ;;
    esac

    # Convert to JSON array
    local hypotheses_json
    hypotheses_json=$(printf '%s\n' "${hypotheses[@]}" | jq -s '.')

    # Store hypotheses
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local new_hypotheses
    new_hypotheses=$(jq -n \
        --arg problem "$problem" \
        --arg context "$context" \
        --arg timestamp "$timestamp" \
        --argjson hypotheses "$hypotheses_json" \
        '{
            problem: $problem,
            context: $context,
            timestamp: $timestamp,
            hypotheses: $hypotheses
        }')

    # Append to state
    jq ".hypotheses += [$new_hypotheses]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Generated ${#hypotheses[@]} hypotheses"

    # Output result
    jq -n \
        --arg problem "$problem" \
        --arg context "$context" \
        --arg timestamp "$timestamp" \
        --argjson hypotheses "$hypotheses_json" \
        '{
            problem: $problem,
            context: $context,
            timestamp: $timestamp,
            hypotheses: $hypotheses,
            recommended_test: $hypotheses[0],
            reasoning: "Generated " + ($hypotheses | length | tostring) + " hypotheses, prioritized by confidence"
        }'
}

# Test a hypothesis
test() {
    local hypothesis_id="$1"
    local evidence="$2"
    local outcome="${3:-}"  # confirmed, refuted, inconclusive

    init_state
    log "Testing hypothesis $hypothesis_id with evidence: $evidence"

    # Find hypothesis
    local hypothesis
    hypothesis=$(jq -r ".hypotheses[].hypotheses[] | select(.id == \"$hypothesis_id\")" "$STATE_FILE")

    if [[ -z "$hypothesis" ]]; then
        echo '{"error": "Hypothesis not found"}' | jq '.'
        return 1
    fi

    # Determine outcome if not provided
    if [[ -z "$outcome" ]]; then
        # Simple heuristic based on evidence
        local evidence_lower
        evidence_lower=$(echo "$evidence" | tr '[:upper:]' '[:lower:]')

        if [[ "$evidence_lower" =~ (confirm|valid|correct|true|success) ]]; then
            outcome="confirmed"
        elif [[ "$evidence_lower" =~ (refute|invalid|wrong|false|fail) ]]; then
            outcome="refuted"
        else
            outcome="inconclusive"
        fi
    fi

    # Record test result
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local test_result
    test_result=$(jq -n \
        --arg hypothesis_id "$hypothesis_id" \
        --arg evidence "$evidence" \
        --arg outcome "$outcome" \
        --arg timestamp "$timestamp" \
        '{
            hypothesis_id: $hypothesis_id,
            evidence: $evidence,
            outcome: $outcome,
            timestamp: $timestamp
        }')

    # Append to state
    jq ".test_results += [$test_result]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Update patterns
    jq ".patterns[\"$hypothesis_id\"] = {outcome: \"$outcome\", timestamp: \"$timestamp\"}" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Hypothesis $hypothesis_id: $outcome"

    # Output result
    jq -n \
        --arg hypothesis_id "$hypothesis_id" \
        --arg evidence "$evidence" \
        --arg outcome "$outcome" \
        --arg timestamp "$timestamp" \
        '{
            hypothesis_id: $hypothesis_id,
            evidence: $evidence,
            outcome: $outcome,
            timestamp: $timestamp,
            next_step: (if $outcome == "confirmed" then "Implement fix based on hypothesis"
                       elif $outcome == "refuted" then "Test next hypothesis"
                       else "Gather more evidence" end)
        }'
}

# Get hypothesis history
history() {
    init_state

    jq '.hypotheses' "$STATE_FILE"
}

# Get test results
results() {
    init_state

    jq '.test_results' "$STATE_FILE"
}

# Get learned patterns
patterns() {
    init_state

    jq '.patterns' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Hypothesis tester state initialized"
        ;;
    generate)
        generate "${2:-problem}" "${3:-}"
        ;;
    test)
        test "${2:-hypothesis_id}" "${3:-evidence}" "${4:-}"
        ;;
    history)
        history
        ;;
    results)
        results
        ;;
    patterns)
        patterns
        ;;
    help|*)
        cat <<EOF
Hypothesis Tester - Generate and Test Hypotheses

Usage:
  $0 generate <problem> [context]
      Generate hypotheses for a problem
  $0 test <hypothesis_id> <evidence> [outcome]
      Test a hypothesis with evidence
  $0 history                             Get hypothesis generation history
  $0 results                             Get test results
  $0 patterns                            Get learned patterns

Hypothesis Types:
  root_cause      - Root cause of the problem
  timing          - Timing-related issues (race conditions)
  data            - Data-related issues (types, formats)
  algorithm       - Algorithmic issues (complexity)
  database        - Database-related issues
  interface       - API/interface issues
  security        - Authentication/authorization issues
  configuration   - Configuration issues
  regression      - Recent changes causing issues

Test Outcomes:
  confirmed       - Hypothesis is correct
  refuted         - Hypothesis is incorrect
  inconclusive    - Need more evidence

Examples:
  $0 generate "API returns 500 error" "production environment"
  $0 test "h1" "Logging shows state mutation at line 42" "confirmed"
  $0 results
EOF
        ;;
esac
