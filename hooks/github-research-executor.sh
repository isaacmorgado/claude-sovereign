#!/bin/bash
# GitHub Research Executor - Autonomous GitHub search execution
# Executes GitHub searches prepared by autonomous-orchestrator-v2.sh
# Outputs formatted research for Claude to use in autonomous mode

set -uo pipefail

CLAUDE_DIR="${HOME}/.claude"
LOG_FILE="${CLAUDE_DIR}/github-research.log"
RESEARCH_CACHE="${CLAUDE_DIR}/.research-cache"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Initialize cache directory
init_cache() {
    mkdir -p "$RESEARCH_CACHE"
}

# Generate cache key from search parameters
get_cache_key() {
    local library="$1"
    local query="$2"
    echo "${library}_$(echo "$query" | md5sum | cut -d' ' -f1)"
}

# Check if research is cached (within 24 hours)
check_cache() {
    local cache_key="$1"
    local cache_file="${RESEARCH_CACHE}/${cache_key}.json"

    if [[ -f "$cache_file" ]]; then
        # Check if cache is less than 24 hours old
        local cache_age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
        if [[ $cache_age -lt 86400 ]]; then
            cat "$cache_file"
            return 0
        fi
    fi
    return 1
}

# Store research in cache
store_cache() {
    local cache_key="$1"
    local data="$2"
    local cache_file="${RESEARCH_CACHE}/${cache_key}.json"
    echo "$data" > "$cache_file"
}

# Execute GitHub search via MCP tool recommendation
# This creates a formatted prompt for Claude to execute the search
execute_search() {
    local research_spec="$1"

    local library=$(echo "$research_spec" | jq -r '.library')
    local query=$(echo "$research_spec" | jq -r '.query')
    local instruction=$(echo "$research_spec" | jq -r '.instruction')
    local parameters=$(echo "$research_spec" | jq -c '.parameters')

    log "Executing GitHub search for library: $library"

    # Check cache first
    local cache_key=$(get_cache_key "$library" "$query")
    local cached_result
    if cached_result=$(check_cache "$cache_key"); then
        log "Using cached research for $library"
        echo "$cached_result"
        return 0
    fi

    # Create research prompt for Claude
    # In autonomous mode, this will be automatically presented to Claude
    # who can then execute the mcp__grep__searchGitHub tool
    local research_prompt=$(jq -n \
        --arg lib "$library" \
        --arg query "$query" \
        --arg instruction "$instruction" \
        --argjson params "$parameters" \
        '{
            library: $lib,
            query: $query,
            instruction: $instruction,
            tool: "mcp__grep__searchGitHub",
            parameters: $params,
            action: "execute_now",
            format: {
                outputType: "formatted_examples",
                maxResults: 5,
                includeContext: true
            }
        }')

    log "Research prompt prepared for $library"
    echo "$research_prompt"
}

# Format search results for Claude consumption
format_results() {
    local library="$1"
    local results="$2"

    if [[ "$results" == "[]" || -z "$results" ]]; then
        echo "No results found for $library"
        return
    fi

    # Create markdown-formatted research summary
    cat << EOF

## 📚 GitHub Research Results: $library

### Code Examples Found

$(echo "$results" | jq -r '.[] | "- **\(.repository)**\n  File: \(.file)\n  \(.snippet)\n"')

### Usage Recommendations

Based on the examples found:
$(echo "$results" | jq -r 'group_by(.pattern) | .[] | "- \(.[0].pattern): Found in \(length) repositories"')

---
EOF
}

# Output research recommendations to stdout (for Claude to read)
output_recommendations() {
    local research_data="$1"

    if [[ -z "$research_data" || "$research_data" == "[]" ]]; then
        return
    fi

    local library=$(echo "$research_data" | jq -r '.library')
    local instruction=$(echo "$research_data" | jq -r '.instruction')

    cat << EOF

╔════════════════════════════════════════════════════════════════╗
║  🔍 AUTO-RESEARCH RECOMMENDATION                               ║
╚════════════════════════════════════════════════════════════════╝

Library: $library
Action: $instruction

To execute this research, use the following tool call:

mcp__grep__searchGitHub with parameters:
$(echo "$research_data" | jq -C '.parameters')

This will provide code examples and implementation patterns for $library.

EOF
}

# Main execution command
run() {
    local research_spec="$1"

    init_cache

    if [[ -z "$research_spec" || "$research_spec" == "[]" ]]; then
        log "No research specification provided"
        return 1
    fi

    local result=$(execute_search "$research_spec")
    output_recommendations "$result"

    # Store for future use
    local library=$(echo "$research_spec" | jq -r '.library')
    local query=$(echo "$research_spec" | jq -r '.query')
    local cache_key=$(get_cache_key "$library" "$query")
    store_cache "$cache_key" "$result"

    log "Research recommendation output for $library"
}

# List cached research
list_cache() {
    if [[ ! -d "$RESEARCH_CACHE" ]]; then
        echo "No cached research available"
        return
    fi

    echo "Cached Research:"
    for cache_file in "$RESEARCH_CACHE"/*.json; do
        if [[ -f "$cache_file" ]]; then
            local library=$(jq -r '.library' "$cache_file" 2>/dev/null || echo "unknown")
            local age=$(($(date +%s) - $(stat -f %m "$cache_file" 2>/dev/null || stat -c %Y "$cache_file" 2>/dev/null || echo 0)))
            local hours=$((age / 3600))
            echo "  - $library (${hours}h old)"
        fi
    done
}

# Clear cache
clear_cache() {
    if [[ -d "$RESEARCH_CACHE" ]]; then
        rm -rf "$RESEARCH_CACHE"/*.json
        log "Research cache cleared"
        echo "Cache cleared"
    fi
}

# Command interface
case "${1:-help}" in
    execute)
        run "${2:-[]}"
        ;;
    list)
        list_cache
        ;;
    clear)
        clear_cache
        ;;
    help|*)
        cat << 'EOF'
GitHub Research Executor

Usage:
  github-research-executor.sh execute <research_spec_json>
  github-research-executor.sh list
  github-research-executor.sh clear

Commands:
  execute  - Execute GitHub search and output recommendations for Claude
  list     - List cached research
  clear    - Clear research cache

Example:
  github-research-executor.sh execute '{"library":"stripe","query":"stripe.checkout","instruction":"Search for Stripe implementation examples"}'

Integration:
  This tool is called automatically by agent-loop.sh when autoResearch
  data is present in the agent state. Claude will see the formatted
  recommendations and can execute the mcp__grep__searchGitHub tool.
EOF
        ;;
esac
