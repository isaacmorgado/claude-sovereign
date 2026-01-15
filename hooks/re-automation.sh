#!/bin/bash
# RE Automation Hook
# Bridges coordinator.sh with the RE skill for automatic tool invocation
# Called by coordinator when RE patterns are detected

set -uo pipefail

RE_SKILL="${HOME}/.claude/skills/re.sh"
RE_DETECTOR="${HOME}/.claude/hooks/re-tool-detector.sh"
LOG_FILE="${HOME}/.claude/logs/re-automation.log"
STATE_FILE="${HOME}/.claude/.re-automation-state.json"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init() {
    mkdir -p "$(dirname "$LOG_FILE")" "$(dirname "$STATE_FILE")"

    if [[ ! -f "$STATE_FILE" ]]; then
        echo '{"last_task":"","last_tool":"","executions":[]}' > "$STATE_FILE"
    fi
}

# =============================================================================
# PROMPT TEMPLATE LOADER (Dynamic injection using envsubst)
# =============================================================================

RE_PROMPTS_FILE="${HOME}/.claude/docs/re-prompts.md"

# Load and interpolate a prompt template from re-prompts.md
# Usage: TARGET="/path/to/app" COMMAND="electron" load_prompt_template "Electron App Analysis"
load_prompt_template() {
    local template_name="$1"
    local prompts_file="${RE_PROMPTS_FILE}"
    
    if [[ ! -f "$prompts_file" ]]; then
        log "Prompts file not found: $prompts_file"
        echo ""
        return 1
    fi
    
    # Extract section by ### header name - macOS compatible
    # Templates are ### sections containing code blocks between triple backticks
    local template
    # Get content from header to next header, excluding the header lines
    template=$(awk "/^### ${template_name}\$/{ found=1; next } /^### /{ found=0 } found" "$prompts_file")
    
    if [[ -z "$template" ]]; then
        log "Template not found: $template_name"
        echo ""
        return 1
    fi
    
    # Inject environment variables using envsubst
    # Expected vars: $TARGET, $COMMAND, $CONTEXT, $OUTPUT_DIR
    echo "$template" | envsubst '$TARGET $COMMAND $CONTEXT $OUTPUT_DIR $APP_NAME $API_URL'
}

# Get a list of available prompt template names
list_prompt_templates() {
    if [[ ! -f "$RE_PROMPTS_FILE" ]]; then
        echo "[]"
        return 1
    fi
    
    grep -E "^##+ " "$RE_PROMPTS_FILE" | sed 's/^##* //' | jq -R -s 'split("\n") | map(select(length > 0))'
}

# =============================================================================
# PATTERN MATCHING FOR RE TASKS
# =============================================================================

# Match task against RE patterns and return appropriate action
match_re_patterns() {
    local task="$1"
    local context="${2:-}"

    local task_lower
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Chrome Extension patterns
    if echo "$task_lower" | grep -qE "(chrome extension|crx file|extract extension|extension source)"; then
        # Try to extract path from task or context
        local crx_path
        crx_path=$(echo "$task $context" | grep -oE '[^ ]+\.crx' | head -1)
        [[ -z "$crx_path" ]] && crx_path=$(echo "$task $context" | grep -oE '~/[^ ]+' | head -1)

        echo "chrome|$crx_path|Extract and analyze Chrome extension"
        return 0
    fi

    # Electron App patterns
    if echo "$task_lower" | grep -qE "(electron app|app\.asar|extract electron|discord|slack|vscode source)"; then
        local app_path
        app_path=$(echo "$task $context" | grep -oE '/Applications/[^/ ]+\.app' | head -1)
        [[ -z "$app_path" ]] && app_path=$(echo "$task $context" | grep -oE '[^ ]+\.app' | head -1)

        echo "electron|$app_path|Extract Electron app source code"
        return 0
    fi

    # JavaScript Deobfuscation patterns
    if echo "$task_lower" | grep -qE "(deobfuscate|beautify|obfuscated|minified|\.min\.js)"; then
        local js_path
        js_path=$(echo "$task $context" | grep -oE '[^ ]+\.js' | head -1)

        echo "deobfuscate|$js_path|Beautify and analyze JavaScript"
        return 0
    fi

    # macOS App patterns
    if echo "$task_lower" | grep -qE "(macos app|app bundle|explore app|info\.plist)"; then
        local app_path
        app_path=$(echo "$task $context" | grep -oE '/Applications/[^/ ]+\.app' | head -1)
        [[ -z "$app_path" ]] && app_path=$(echo "$task $context" | grep -oE '[^ ]+\.app' | head -1)

        echo "macos|$app_path|Explore macOS app bundle"
        return 0
    fi

    # API Research patterns
    if echo "$task_lower" | grep -qE "(reverse engineer.*api|api research|figure out.*api|intercept.*traffic)"; then
        local api_url
        api_url=$(echo "$task $context" | grep -oE 'https?://[^ ]+' | head -1)

        echo "api|$api_url|Start API reverse engineering"
        return 0
    fi

    # Generic RE analysis patterns (expanded for broader NLP matching)
    if echo "$task_lower" | grep -qE "(reverse engineer|analyze|extract|figure out|look into|understand|deconstruct|decode|examine|inspect|investigate|dissect|explore).*(source|binary|app|code|api|protocol|extension|bundle|executable|library|dll|so|dylib|framework)"; then
        local target_path
        target_path=$(echo "$task $context" | grep -oE '[^ ]+\.(app|crx|js|asar|exe|dll|so|dylib|framework)' | head -1)

        echo "analyze|$target_path|Auto-analyze target"
        return 0
    fi

    # No match
    return 1
}

# =============================================================================
# EXECUTION FUNCTIONS
# =============================================================================

# Execute RE skill with detected parameters
execute_re_task() {
    local task="$1"
    local context="${2:-}"

    log "Analyzing task for RE automation: $task"

    # Match patterns
    local match_result
    match_result=$(match_re_patterns "$task" "$context") || {
        log "No RE pattern matched"
        echo '{"matched":false,"task":"'"$task"'"}'
        return 1
    }

    # Parse match result
    local command target description
    command=$(echo "$match_result" | cut -d'|' -f1)
    target=$(echo "$match_result" | cut -d'|' -f2)
    description=$(echo "$match_result" | cut -d'|' -f3)

    log "RE pattern matched: command=$command, target=$target"

    # Validate target exists (if path-based)
    if [[ -n "$target" && "$command" != "api" ]]; then
        if [[ ! -e "$target" ]]; then
            log "Target not found: $target"

            # Return suggestion without execution
            cat << EOF
{
  "matched": true,
  "command": "$command",
  "target": "$target",
  "description": "$description",
  "executed": false,
  "error": "Target path not found",
  "suggestion": "Please provide the correct path to the target",
  "skill_command": "$RE_SKILL $command <path>"
}
EOF
            return 0
        fi
    fi

    # Execute the skill
    log "Executing: $RE_SKILL $command $target"

    local start_time output exit_code
    start_time=$(date +%s)

    if [[ -n "$target" ]]; then
        output=$("$RE_SKILL" "$command" "$target" 2>&1)
        exit_code=$?
    else
        # No target - return instruction
        cat << EOF
{
  "matched": true,
  "command": "$command",
  "target": null,
  "description": "$description",
  "executed": false,
  "needsTarget": true,
  "skill_command": "$RE_SKILL $command <path>"
}
EOF
        return 0
    fi

    local end_time duration
    end_time=$(date +%s)
    duration=$((end_time - start_time))

    # Update state
    update_state "$command" "$target" "$exit_code"

    if [[ $exit_code -eq 0 ]]; then
        log "RE task completed successfully in ${duration}s"

        # Extract analysis JSON from output (last JSON block)
        local analysis_json
        analysis_json=$(echo "$output" | grep -E '^\{' | tail -1)

        cat << EOF
{
  "matched": true,
  "command": "$command",
  "target": "$target",
  "description": "$description",
  "executed": true,
  "success": true,
  "duration": $duration,
  "analysis": $analysis_json
}
EOF
    else
        log "RE task failed with exit code $exit_code"

        cat << EOF
{
  "matched": true,
  "command": "$command",
  "target": "$target",
  "description": "$description",
  "executed": true,
  "success": false,
  "exitCode": $exit_code,
  "error": "$(echo "$output" | tail -5 | tr '\n' ' ' | sed 's/"/\\"/g')"
}
EOF
    fi
}

# Check if task is RE-related (quick check for coordinator)
is_re_task() {
    local task="$1"
    local task_lower
    task_lower=$(echo "$task" | tr '[:upper:]' '[:lower:]')

    # Quick keyword check (expanded for broader NLP matching)
    if echo "$task_lower" | grep -qE "(reverse engineer|extract.*extension|chrome.*crx|electron.*app|deobfuscate|beautify.*js|macos.*app|app\.asar|\.crx|analyze.*source|figure out|look into|understand|deconstruct|decode|examine|inspect|investigate|dissect|explore).*(binary|app|code|api|protocol|extension|bundle|executable|library|dll|so|dylib|framework|source)?"; then
        echo "true"
        return 0
    fi

    # Use detector for more thorough check
    if [[ -x "$RE_DETECTOR" ]]; then
        local detection
        detection=$("$RE_DETECTOR" detect "$task" "" "[]" 2>/dev/null)
        if [[ -n "$detection" && "$detection" != "{}" ]]; then
            echo "true"
            return 0
        fi
    fi

    echo "false"
    return 1
}

# Get RE tool recommendation from detector
get_re_recommendation() {
    local task="$1"
    local context="${2:-}"

    # First try our pattern matching
    local match_result
    match_result=$(match_re_patterns "$task" "$context" 2>/dev/null) && {
        local command target description
        command=$(echo "$match_result" | cut -d'|' -f1)
        target=$(echo "$match_result" | cut -d'|' -f2)
        description=$(echo "$match_result" | cut -d'|' -f3)

        cat << EOF
{
  "detected": true,
  "source": "re-automation",
  "command": "$command",
  "target": "$target",
  "description": "$description",
  "skill_command": "$RE_SKILL $command ${target:-<path>}"
}
EOF
        return 0
    }

    # Fall back to detector
    if [[ -x "$RE_DETECTOR" ]]; then
        local detection
        detection=$("$RE_DETECTOR" detect "$task" "$context" "[]" 2>/dev/null)

        if [[ -n "$detection" && "$detection" != "{}" ]]; then
            echo "$detection" | jq '. + {"detected":true,"source":"re-tool-detector"}'
            return 0
        fi
    fi

    echo '{"detected":false}'
    return 1
}

# Update execution state
update_state() {
    local command="$1"
    local target="$2"
    local exit_code="$3"

    local temp_file
    temp_file=$(mktemp)

    jq --arg cmd "$command" \
       --arg target "$target" \
       --argjson exit "$exit_code" \
       --arg time "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
       '.last_task = $cmd |
        .last_tool = $cmd |
        .executions += [{"command":$cmd,"target":$target,"exitCode":$exit,"time":$time}] |
        .executions = .executions[-10:]' \
       "$STATE_FILE" > "$temp_file"

    mv "$temp_file" "$STATE_FILE"
}

# =============================================================================
# MAIN INTERFACE
# =============================================================================

init

case "${1:-help}" in
    execute)
        # Execute RE task automatically
        execute_re_task "${2:-}" "${3:-}"
        ;;

    is-re|check)
        # Quick check if task is RE-related
        is_re_task "${2:-}"
        ;;

    recommend|detect)
        # Get RE tool recommendation
        get_re_recommendation "${2:-}" "${3:-}"
        ;;

    match)
        # Test pattern matching
        match_re_patterns "${2:-}" "${3:-}"
        ;;

    status)
        # Show current state
        cat "$STATE_FILE"
        ;;

    list-templates)
        # List available prompt templates
        list_prompt_templates
        ;;

    get-prompt)
        # Get a prompt template with variable injection
        # Usage: get-prompt "Template Name"
        load_prompt_template "${2:-}"
        ;;

    help|*)
        cat << 'EOF'
RE Automation Hook
==================

Bridges coordinator.sh with the RE skill for automatic tool invocation.

USAGE:
    re-automation.sh <command> [args]

COMMANDS:
    execute <task> [context]    Execute RE task automatically
    is-re <task>                Check if task is RE-related (returns true/false)
    recommend <task> [context]  Get RE tool recommendation
    match <task> [context]      Test pattern matching
    status                      Show execution history

INTEGRATION:
    Called by coordinator.sh when RE patterns are detected.
    Automatically invokes ~/.claude/skills/re.sh with appropriate parameters.

PATTERNS DETECTED:
    - Chrome extension extraction
    - Electron app source extraction
    - JavaScript deobfuscation
    - macOS app exploration
    - API reverse engineering

EXAMPLES:
    re-automation.sh is-re "extract chrome extension"
    re-automation.sh execute "reverse engineer /Applications/Slack.app"
    re-automation.sh recommend "deobfuscate bundle.min.js"

EOF
        ;;
esac
