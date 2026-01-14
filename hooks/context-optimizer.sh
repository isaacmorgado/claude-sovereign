#!/bin/bash
# Context Optimizer - Optimize Context for LLM Interactions
# Manages context window, prioritization, and compression for optimal LLM performance
# Usage: context-optimizer.sh optimize <context> <task> [max_tokens]

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/context-optimizer.log"
STATE_FILE="${HOME}/.claude/context-optimizer-state.json"

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
    "optimizations": [],
    "patterns": {
        "high_priority": [
            "error_messages",
            "stack_traces",
            "test_failures",
            "user_requirements",
            "recent_changes"
        ],
        "medium_priority": [
            "code_context",
            "configuration",
            "documentation",
            "related_issues"
        ],
        "low_priority": [
            "historical_context",
            "verbose_logs",
            "debug_output",
            "comments"
        ]
    }
}
EOF
    fi
}

# Estimate token count (rough approximation)
estimate_tokens() {
    local text="$1"
    # Rough estimate: ~4 characters per token for English text
    local char_count
    char_count=$(echo -n "$text" | wc -c | tr -d ' ')
    local token_estimate=$((char_count / 4))
    echo "$token_estimate"
}

# Optimize context for LLM interaction
optimize() {
    local context="$1"
    local task="$2"
    local max_tokens="${3:-100000}"  # Default to 100k tokens (Claude's large context)

    init_state
    log "Optimizing context for task: $task (max_tokens: $max_tokens)"

    # Parse context (assuming JSON format)
    local context_json
    if echo "$context" | jq -e '.' > /dev/null 2>&1; then
        context_json="$context"
    else
        # If not JSON, wrap in simple structure
        context_json=$(jq -n --arg text "$context" '{text: $text}')
    fi

    # Calculate current token count
    local context_text
    context_text=$(echo "$context_json" | jq -r 'tostring')
    local current_tokens
    current_tokens=$(estimate_tokens "$context_text")

    log "Current context size: ~$current_tokens tokens"

    # If context is within limits, return as-is
    if [[ $current_tokens -le $max_tokens ]]; then
        jq -n \
            --arg task "$task" \
            --argjson context "$context_json" \
            --argjson current_tokens "$current_tokens" \
            --argjson max_tokens "$max_tokens" \
            '{
                task: $task,
                optimized: false,
                reason: "Context within token limits",
                current_tokens: $current_tokens,
                max_tokens: $max_tokens,
                context: $context
            }'
        return
    fi

    # Context exceeds limits, need to optimize
    log "Context exceeds limits, applying optimization strategies"

    # Strategy 1: Prioritize by importance
    local optimized_context
    optimized_context=$(echo "$context_json" | jq '.')

    # Strategy 2: Remove low-priority elements
    optimized_context=$(echo "$optimized_context" | jq 'del(.debug_output, .verbose_logs, .historical_context)')

    # Strategy 3: Compress code snippets (keep only relevant parts)
    optimized_context=$(echo "$optimized_context" | jq 'with_entries(
        if .key | test("code_.*") then
            .value |= (if type == "array" then .[0:100] else . end)
        else
            .
        end
    )')

    # Strategy 4: Truncate long strings
    optimized_context=$(echo "$optimized_context" | jq 'with_entries(
        if .value | type == "string" and length > 5000 then
            .value |= .[0:5000] + "... [truncated]"
        else
            .
        end
    )')

    # Recalculate token count
    local optimized_text
    optimized_text=$(echo "$optimized_context" | jq -r 'tostring')
    local optimized_tokens
    optimized_tokens=$(estimate_tokens "$optimized_text")

    log "Optimized context size: ~$optimized_tokens tokens"

    # If still over limits, apply more aggressive strategies
    if [[ $optimized_tokens -gt $max_tokens ]]; then
        log "Still over limits, applying aggressive optimization"

        # Keep only high-priority fields
        optimized_context=$(echo "$optimized_context" | jq 'with_entries(
            select(.key | test("error|stack|test|requirement|change", "i"))
        )')

        # Limit to top 20 fields
        optimized_context=$(echo "$optimized_context" | jq 'with_entries(select(.key != "")) | to_entries | .[0:20] | from_entries')

        optimized_text=$(echo "$optimized_context" | jq -r 'tostring')
        optimized_tokens=$(estimate_tokens "$optimized_text")
    fi

    # Record optimization
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local optimization
    optimization=$(jq -n \
        --arg task "$task" \
        --arg timestamp "$timestamp" \
        --argjson original_tokens "$current_tokens" \
        --argjson optimized_tokens "$optimized_tokens" \
        --argjson max_tokens "$max_tokens" \
        --argjson reduction_ratio "$(echo "scale=2; ($current_tokens - $optimized_tokens) / $current_tokens" | bc)" \
        '{
            task: $task,
            timestamp: $timestamp,
            original_tokens: $original_tokens,
            optimized_tokens: $optimized_tokens,
            max_tokens: $max_tokens,
            reduction_ratio: $reduction_ratio
        }')

    jq ".optimizations += [$optimization]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    # Output result
    jq -n \
        --arg task "$task" \
        --argjson context "$optimized_context" \
        --argjson original_tokens "$current_tokens" \
        --argjson optimized_tokens "$optimized_tokens" \
        --argjson max_tokens "$max_tokens" \
        --argjson reduction_ratio "$(echo "scale=2; ($current_tokens - $optimized_tokens) / $current_tokens" | bc)" \
        '{
            task: $task,
            optimized: true,
            reason: "Context exceeded token limits",
            original_tokens: $original_tokens,
            optimized_tokens: $optimized_tokens,
            max_tokens: $max_tokens,
            reduction_ratio: $reduction_ratio,
            strategies_applied: ["priority_filtering", "low_priority_removal", "code_compression", "string_truncation"],
            context: $context
        }'
}

# Add context element with priority
add_element() {
    local key="$1"
    local value="$2"
    local priority="${3:-medium}"  # high, medium, low

    init_state
    log "Adding context element: $key (priority: $priority)"

    # Validate priority
    if [[ ! "$priority" =~ ^(high|medium|low)$ ]]; then
        echo '{"error": "Invalid priority. Use: high, medium, or low"}' | jq '.'
        return 1
    fi

    jq -n \
        --arg key "$key" \
        --arg value "$value" \
        --arg priority "$priority" \
        '{
            key: $key,
            value: $value,
            priority: $priority,
            timestamp: (now | todateiso8601)
        }'
}

# Get optimization patterns
patterns() {
    init_state

    jq '.patterns' "$STATE_FILE"
}

# Get optimization history
history() {
    init_state

    jq '.optimizations' "$STATE_FILE"
}

# Analyze context for optimization opportunities
analyze() {
    local context="$1"

    init_state
    log "Analyzing context for optimization opportunities"

    # Parse context
    local context_json
    if echo "$context" | jq -e '.' > /dev/null 2>&1; then
        context_json="$context"
    else
        context_json=$(jq -n --arg text "$context" '{text: $text}')
    fi

    # Analyze context structure
    local key_count
    key_count=$(echo "$context_json" | jq 'length')

    local total_size
    total_size=$(echo "$context_json" | jq -r 'tostring' | wc -c | tr -d ' ')

    local large_fields
    large_fields=$(echo "$context_json" | jq 'with_entries(select(.value | type == "string" and length > 1000)) | keys')

    local code_fields
    code_fields=$(echo "$context_json" | jq 'keys | map(select(test("code|snippet|source", "i")))')

    # Generate recommendations
    local recommendations=()

    if [[ $key_count -gt 50 ]]; then
        recommendations+=('{"priority": "high", "action": "reduce_fields", "reason": "Too many keys ('"$key_count"')", "suggestion": "Merge related fields or remove unused ones"}')
    fi

    if [[ $total_size -gt 100000 ]]; then
        recommendations+=('{"priority": "high", "action": "compress", "reason": "Context too large ('"$total_size"' bytes)", "suggestion": "Apply compression strategies"}')
    fi

    if [[ $(echo "$large_fields" | jq 'length') -gt 0 ]]; then
        recommendations+=('{"priority": "medium", "action": "truncate_strings", "reason": "Large string fields found", "suggestion": "Truncate or summarize large strings"}')
    fi

    if [[ $(echo "$code_fields" | jq 'length') -gt 0 ]]; then
        recommendations+=('{"priority": "medium", "action": "compress_code", "reason": "Code fields present", "suggestion": "Compress code snippets to essential parts"}')
    fi

    local recommendations_json
    recommendations_json=$(printf '%s\n' "${recommendations[@]}" | jq -s '.')

    # Output analysis
    jq -n \
        --argjson key_count "$key_count" \
        --argjson total_size "$total_size" \
        --argjson large_fields "$large_fields" \
        --argjson code_fields "$code_fields" \
        --argjson recommendations "$recommendations_json" \
        '{
            key_count: $key_count,
            total_size_bytes: $total_size,
            large_fields: $large_fields,
            code_fields: $code_fields,
            recommendations: $recommendations,
            optimization_needed: ($recommendations | length > 0)
        }'
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Context optimizer state initialized"
        ;;
    optimize)
        optimize "${2:-context}" "${3:-task}" "${4:-100000}"
        ;;
    add)
        add_element "${2:-key}" "${3:-value}" "${4:-medium}"
        ;;
    patterns)
        patterns
        ;;
    history)
        history
        ;;
    analyze)
        analyze "${2:-context}"
        ;;
    help|*)
        cat <<EOF
Context Optimizer - Optimize Context for LLM Interactions

Usage:
  $0 optimize <context> <task> [max_tokens]
      Optimize context for LLM interaction
  $0 add <key> <value> [priority]
      Add context element with priority
  $0 patterns                            Get optimization patterns
  $0 history                             Get optimization history
  $0 analyze <context>                   Analyze context for optimization

Priority Levels:
  high      - Critical information (errors, failures, requirements)
  medium    - Important context (code, config, docs)
  low       - Optional information (history, logs, comments)

Optimization Strategies:
  1. Priority-based filtering
  2. Low-priority element removal
  3. Code snippet compression
  4. String truncation
  5. Field count limiting

Examples:
  $0 optimize '{"error": "stack trace", "code": "function() {..."}' "debug task"
  $0 add "error_message" "Null pointer exception" "high"
  $0 analyze '{"large": "very long string..."}'
EOF
        ;;
esac
