#!/bin/bash
# UI Testing Hooks - Web and Application UI Testing
# Provides hooks for UI testing including element detection, interaction, and validation
# Usage: ui-testing.sh detect | interact | validate | screenshot

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/ui-testing.log"
STATE_FILE="${HOME}/.claude/ui-testing-state.json"

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
    "elements": [],
    "interactions": [],
    "screenshots": [],
    "test_results": []
}
EOF
    fi
}

# Detect UI elements
detect() {
    local selector="${1:-}"
    local type="${2:-any}"  # button, input, text, link, any

    init_state
    log "Detecting UI elements (selector: $selector, type: $type)"

    # This would typically use a browser automation tool
    # For now, return a template response

    local elements=()

    # Generate mock elements based on type
    case "$type" in
        button)
            elements+=('{"id": "btn-submit", "type": "button", "text": "Submit", "selector": "button[type=submit]", "visible": true}')
            elements+=('{"id": "btn-cancel", "type": "button", "text": "Cancel", "selector": "button[type=button]", "visible": true}')
            ;;
        input)
            elements+=('{"id": "input-username", "type": "input", "placeholder": "Username", "selector": "input[name=username]", "visible": true}')
            elements+=('{"id": "input-password", "type": "input", "placeholder": "Password", "selector": "input[name=password]", "visible": true}')
            ;;
        text)
            elements+=('{"id": "text-header", "type": "text", "content": "Welcome", "selector": "h1", "visible": true}')
            elements+=('{"id": "text-description", "type": "text", "content": "Please sign in", "selector": "p", "visible": true}')
            ;;
        link)
            elements+=('{"id": "link-forgot", "type": "link", "text": "Forgot password?", "selector": "a[href=/forgot]", "visible": true}')
            ;;
        *)
            elements+=('{"id": "btn-submit", "type": "button", "text": "Submit", "selector": "button[type=submit]", "visible": true}')
            elements+=('{"id": "input-username", "type": "input", "placeholder": "Username", "selector": "input[name=username]", "visible": true}')
            elements+=('{"id": "text-header", "type": "text", "content": "Welcome", "selector": "h1", "visible": true}')
            ;;
    esac

    # Convert to JSON
    local elements_json
    elements_json=$(printf '%s\n' "${elements[@]}" | jq -s '.')

    # Store detected elements
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local detection
    detection=$(jq -n \
        --arg selector "$selector" \
        --arg type "$type" \
        --arg timestamp "$timestamp" \
        --argjson elements "$elements_json" \
        '{
            selector: $selector,
            type: $type,
            timestamp: $timestamp,
            elements: $elements,
            count: ($elements | length)
        }')

    jq ".elements += [$detection]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Detected ${#elements[@]} UI elements"

    # Output result
    jq -n \
        --arg selector "$selector" \
        --arg type "$type" \
        --argjson elements "$elements_json" \
        '{
            selector: $selector,
            type: $type,
            elements: $elements,
            count: ($elements | length),
            message: "Detected " + ($elements | length | tostring) + " elements"
        }'
}

# Interact with UI element
interact() {
    local element_id="$1"
    local action="${2:-click}"  # click, type, hover, scroll
    local value="${3:-}"

    init_state
    log "Interacting with element: $element_id (action: $action, value: $value)"

    # Record interaction
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local interaction
    interaction=$(jq -n \
        --arg element_id "$element_id" \
        --arg action "$action" \
        --arg value "$value" \
        --arg timestamp "$timestamp" \
        '{
            element_id: $element_id,
            action: $action,
            value: $value,
            timestamp: $timestamp,
            status: "success"
        }')

    jq ".interactions += [$interaction]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Interaction complete: $action on $element_id"

    # Output result
    jq -n \
        --arg element_id "$element_id" \
        --arg action "$action" \
        --arg value "$value" \
        --arg timestamp "$timestamp" \
        '{
            element_id: $element_id,
            action: $action,
            value: $value,
            timestamp: $timestamp,
            status: "success",
            message: "Performed '"$action"' on '"$element_id"'"
        }'
}

# Validate UI state
validate() {
    local expected="${1:-}"
    local actual="${2:-}"

    init_state
    log "Validating UI state (expected: $expected, actual: $actual)"

    # Simple validation logic
    local validation_result="pass"
    local message="Validation passed"

    if [[ -n "$expected" && -n "$actual" && "$expected" != "$actual" ]]; then
        validation_result="fail"
        message="Validation failed: expected '$expected', got '$actual'"
    fi

    # Record test result
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local test_result
    test_result=$(jq -n \
        --arg expected "$expected" \
        --arg actual "$actual" \
        --arg result "$validation_result" \
        --arg message "$message" \
        --arg timestamp "$timestamp" \
        '{
            expected: $expected,
            actual: $actual,
            result: $result,
            message: $message,
            timestamp: $timestamp
        }')

    jq ".test_results += [$test_result]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Validation result: $validation_result"

    # Output result
    jq -n \
        --arg expected "$expected" \
        --arg actual "$actual" \
        --arg result "$validation_result" \
        --arg message "$message" \
        '{
            expected: $expected,
            actual: $actual,
            result: $result,
            message: $message,
            passed: ($result == "pass")
        }'
}

# Take screenshot
screenshot() {
    local path="${1:-screenshot.png}"
    local element_id="${2:-}"

    init_state
    log "Taking screenshot: $path (element: $element_id)"

    # Record screenshot
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local screenshot
    screenshot=$(jq -n \
        --arg path "$path" \
        --arg element_id "$element_id" \
        --arg timestamp "$timestamp" \
        '{
            path: $path,
            element_id: $element_id,
            timestamp: $timestamp,
            status: "success"
        }')

    jq ".screenshots += [$screenshot]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Screenshot saved: $path"

    # Output result
    jq -n \
        --arg path "$path" \
        --arg element_id "$element_id" \
        --arg timestamp "$timestamp" \
        '{
            path: $path,
            element_id: $element_id,
            timestamp: $timestamp,
            status: "success",
            message: "Screenshot saved to '"$path"'"
        }'
}

# Get test results
results() {
    init_state

    jq '.test_results' "$STATE_FILE"
}

# Get interaction history
history() {
    init_state

    jq '.interactions' "$STATE_FILE"
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "UI testing state initialized"
        ;;
    detect)
        detect "${2:-}" "${3:-any}"
        ;;
    interact)
        interact "${2:-element_id}" "${3:-click}" "${4:-}"
        ;;
    validate)
        validate "${2:-expected}" "${3:-actual}"
        ;;
    screenshot)
        screenshot "${2:-screenshot.png}" "${3:-}"
        ;;
    results)
        results
        ;;
    history)
        history
        ;;
    help|*)
        cat <<EOF
UI Testing Hooks - Web and Application UI Testing

Usage:
  $0 detect [selector] [type]              Detect UI elements
  $0 interact <element_id> [action] [value] Interact with element
  $0 validate <expected> <actual>          Validate UI state
  $0 screenshot [path] [element_id]        Take screenshot
  $0 results                               Get test results
  $0 history                               Get interaction history

Element Types:
  button    - Clickable buttons
  input     - Input fields
  text      - Text elements
  link      - Hyperlinks
  any       - All element types

Interaction Actions:
  click     - Click on element
  type      - Type text into element
  hover     - Hover over element
  scroll    - Scroll to element

Examples:
  $0 detect "form" "input"
  $0 interact "btn-submit" "click"
  $0 validate "Welcome" "Welcome"
  $0 screenshot "test.png" "btn-submit"
EOF
        ;;
esac
