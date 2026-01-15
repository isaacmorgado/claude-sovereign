#!/bin/bash
# Hypothesis Tester - Test hypotheses before implementation

set -uo pipefail

HYPOTHESIS_DIR="${HOME}/.claude/hypotheses"
ACTIVE_HYPOTHESES="$HYPOTHESIS_DIR/active.json"
RESULTS="$HYPOTHESIS_DIR/results.jsonl"
LOG_FILE="${HOME}/.claude/hypothesis-tester.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_hypothesis() {
    mkdir -p "$HYPOTHESIS_DIR"
    [[ -f "$ACTIVE_HYPOTHESES" ]] || echo '{"hypotheses":[]}' > "$ACTIVE_HYPOTHESES"
    [[ -f "$RESULTS" ]] || touch "$RESULTS"
}

# State a hypothesis
state_hypothesis() {
    local hypothesis="$1"
    local expected_outcome="$2"
    local task="${3:-}"

    init_hypothesis

    local hypothesis_id
    hypothesis_id="hyp_$(date +%s)"
    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local temp_file
    temp_file=$(mktemp)

    jq --arg id "$hypothesis_id" \
       --arg hyp "$hypothesis" \
       --arg expected "$expected_outcome" \
       --arg task "$task" \
       --arg ts "$timestamp" \
       '.hypotheses += [{
           id: $id,
           hypothesis: $hyp,
           expectedOutcome: $expected,
           task: $task,
           status: "pending",
           createdAt: $ts
       }]' "$ACTIVE_HYPOTHESES" > "$temp_file"

    mv "$temp_file" "$ACTIVE_HYPOTHESES"

    log "Stated hypothesis: $hypothesis_id"
    echo "{\"id\":\"$hypothesis_id\",\"hypothesis\":\"$hypothesis\"}"
}

# Verify hypothesis against actual outcome
verify_hypothesis() {
    local hypothesis_id="$1"
    local actual_outcome="$2"
    local details="${3:-}"

    init_hypothesis

    local hypothesis
    hypothesis=$(jq -r --arg id "$hypothesis_id" '.hypotheses[] | select(.id == $id)' "$ACTIVE_HYPOTHESES")

    if [[ -z "$hypothesis" || "$hypothesis" == "null" ]]; then
        echo "{\"error\":\"Hypothesis not found\"}"
        return 1
    fi

    local expected
    expected=$(echo "$hypothesis" | jq -r '.expectedOutcome')

    local result
    if [[ "$expected" == "$actual_outcome" ]]; then
        result="correct"
    else
        result="incorrect"
    fi

    # Record result
    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)
    local record
    record=$(echo "$hypothesis" | jq --arg result "$result" \
        --arg actual "$actual_outcome" \
        --arg details "$details" \
        --arg ts "$timestamp" \
        '. + {result: $result, actualOutcome: $actual, details: $details, verifiedAt: $ts}')

    echo "$record" >> "$RESULTS"

    # Remove from active
    local temp_file
    temp_file=$(mktemp)
    jq --arg id "$hypothesis_id" '.hypotheses = [.hypotheses[] | select(.id != $id)]' \
        "$ACTIVE_HYPOTHESES" > "$temp_file"
    mv "$temp_file" "$ACTIVE_HYPOTHESES"

    log "Verified hypothesis $hypothesis_id: $result"
    echo "$record"
}

# Get accuracy of hypotheses
get_accuracy() {
    init_hypothesis

    local total
    total=$(wc -l < "$RESULTS" 2>/dev/null || echo "0")
    [[ $total -eq 0 ]] && echo '{"accuracy":0,"total":0}' && return

    local correct
    correct=$(grep '"result":"correct"' "$RESULTS" 2>/dev/null | wc -l | tr -d ' ')

    local accuracy
    accuracy=$((correct * 100 / total))

    echo "{\"accuracy\":$accuracy,\"correct\":$correct,\"total\":$total}"
}

case "${1:-help}" in
    state) state_hypothesis "${2:-hypothesis}" "${3:-outcome}" "${4:-}" ;;
    verify) verify_hypothesis "${2:-hyp_id}" "${3:-outcome}" "${4:-}" ;;
    accuracy) get_accuracy ;;
    *) echo "Usage: $0 {state|verify|accuracy} [args]" ;;
esac
