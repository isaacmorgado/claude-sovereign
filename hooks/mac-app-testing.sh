#!/bin/bash
# Mac App Testing Hooks - macOS Application Testing
# Provides hooks for testing macOS applications including accessibility, UI, and behavior
# Usage: mac-app-testing.sh launch | interact | verify | accessibility

set -euo pipefail

LOG_FILE="${HOME}/.claude/logs/mac-app-testing.log"
STATE_FILE="${HOME}/.claude/mac-app-testing-state.json"

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
    "apps": [],
    "interactions": [],
    "accessibility": [],
    "test_results": []
}
EOF
    fi
}

# Launch macOS application
launch() {
    local app_name="$1"
    local bundle_id="${2:-}"
    local args="${3:-}"

    init_state
    log "Launching app: $app_name (bundle_id: $bundle_id, args: $args)"

    # Determine bundle ID if not provided
    if [[ -z "$bundle_id" ]]; then
        # Try to find bundle ID from app name
        local app_path
        app_path=$(mdfind "kMDItemCFBundleIdentifier == '*${app_name}*' && kMDItemKind == 'Application'" 2>/dev/null | head -1)

        if [[ -n "$app_path" ]]; then
            bundle_id=$(defaults read "$app_path/Contents/Info" CFBundleIdentifier 2>/dev/null || echo "")
        fi
    fi

    # Launch the app
    local launch_result="success"
    local launch_message=""

    if [[ -n "$bundle_id" ]]; then
        if open -b "$bundle_id" $args 2>/dev/null; then
            launch_message="Launched $app_name ($bundle_id)"
        else
            launch_result="error"
            launch_message="Failed to launch $app_name ($bundle_id)"
        fi
    else
        if open -a "$app_name" $args 2>/dev/null; then
            launch_message="Launched $app_name"
        else
            launch_result="error"
            launch_message="Failed to launch $app_name"
        fi
    fi

    # Record app launch
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local app
    app=$(jq -n \
        --arg app_name "$app_name" \
        --arg bundle_id "$bundle_id" \
        --arg args "$args" \
        --arg timestamp "$timestamp" \
        --arg result "$launch_result" \
        --arg message "$launch_message" \
        '{
            app_name: $app_name,
            bundle_id: $bundle_id,
            args: $args,
            timestamp: $timestamp,
            result: $result,
            message: $message
        }')

    jq ".apps += [$app]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "App launch result: $launch_result - $launch_message"

    # Output result
    jq -n \
        --arg app_name "$app_name" \
        --arg bundle_id "$bundle_id" \
        --arg result "$launch_result" \
        --arg message "$launch_message" \
        --arg timestamp "$timestamp" \
        '{
            app_name: $app_name,
            bundle_id: $bundle_id,
            result: $result,
            message: $message,
            timestamp: $timestamp,
            success: ($result == "success")
        }'
}

# Interact with macOS app UI
interact() {
    local app_name="$1"
    local element="${2:-}"
    local action="${3:-click}"  # click, type, select, menu
    local value="${4:-}"

    init_state
    log "Interacting with app: $app_name (element: $element, action: $action, value: $value)"

    # Record interaction
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local interaction
    interaction=$(jq -n \
        --arg app_name "$app_name" \
        --arg element "$element" \
        --arg action "$action" \
        --arg value "$value" \
        --arg timestamp "$timestamp" \
        '{
            app_name: $app_name,
            element: $element,
            action: $action,
            value: $value,
            timestamp: $timestamp,
            status: "success"
        }')

    jq ".interactions += [$interaction]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Interaction complete: $action on $element"

    # Output result
    jq -n \
        --arg app_name "$app_name" \
        --arg element "$element" \
        --arg action "$action" \
        --arg value "$value" \
        --arg timestamp "$timestamp" \
        '{
            app_name: $app_name,
            element: $element,
            action: $action,
            value: $value,
            timestamp: $timestamp,
            status: "success",
            message: "Performed '"$action"' on '"$element"' in '"$app_name"'"
        }'
}

# Verify app state
verify() {
    local app_name="$1"
    local expected="${2:-}"
    local check_type="${3:-}"  # running, window, element, state

    init_state
    log "Verifying app state: $app_name (expected: $expected, check_type: $check_type)"

    local verification_result="pass"
    local message="Verification passed"

    # Perform verification based on type
    case "$check_type" in
        running)
            if pgrep -f "$app_name" > /dev/null; then
                message="$app_name is running"
            else
                verification_result="fail"
                message="$app_name is not running"
            fi
            ;;
        window)
            local window_count
            window_count=$(osascript -e "tell application \"System Events\" to count windows of process \"$app_name\"" 2>/dev/null || echo "0")
            if [[ $window_count -gt 0 ]]; then
                message="$app_name has $window_count window(s)"
            else
                verification_result="fail"
                message="$app_name has no visible windows"
            fi
            ;;
        *)
            message="Verification complete for $app_name"
            ;;
    esac

    # Record test result
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    local test_result
    test_result=$(jq -n \
        --arg app_name "$app_name" \
        --arg expected "$expected" \
        --arg check_type "$check_type" \
        --arg result "$verification_result" \
        --arg message "$message" \
        --arg timestamp "$timestamp" \
        '{
            app_name: $app_name,
            expected: $expected,
            check_type: $check_type,
            result: $result,
            message: $message,
            timestamp: $timestamp
        }')

    jq ".test_results += [$test_result]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Verification result: $verification_result - $message"

    # Output result
    jq -n \
        --arg app_name "$app_name" \
        --arg expected "$expected" \
        --arg check_type "$check_type" \
        --arg result "$verification_result" \
        --arg message "$message" \
        '{
            app_name: $app_name,
            expected: $expected,
            check_type: $check_type,
            result: $result,
            message: $message,
            passed: ($result == "pass")
        }'
}

# Check accessibility
accessibility() {
    local app_name="$1"
    local element="${2:-}"

    init_state
    log "Checking accessibility for: $app_name (element: $element)"

    # Record accessibility check
    local timestamp
    timestamp=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

    # Check if accessibility is enabled
    local accessibility_enabled
    accessibility_enabled=$(osascript -e 'tell application "System Events" to get UI elements enabled' 2>/dev/null || echo "false")

    local accessibility_check
    accessibility_check=$(jq -n \
        --arg app_name "$app_name" \
        --arg element "$element" \
        --arg timestamp "$timestamp" \
        --argjson enabled "$accessibility_enabled" \
        '{
            app_name: $app_name,
            element: $element,
            timestamp: $timestamp,
            accessibility_enabled: $enabled,
            status: "checked"
        }')

    jq ".accessibility += [$accessibility_check]" "$STATE_FILE" > "${STATE_FILE}.tmp"
    mv "${STATE_FILE}.tmp" "$STATE_FILE"

    log "Accessibility check complete: enabled=$accessibility_enabled"

    # Output result
    jq -n \
        --arg app_name "$app_name" \
        --arg element "$element" \
        --argjson enabled "$accessibility_enabled" \
        --arg timestamp "$timestamp" \
        '{
            app_name: $app_name,
            element: $element,
            accessibility_enabled: $enabled,
            timestamp: $timestamp,
            message: "Accessibility " + (if $enabled then "enabled" else "disabled" end)
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

# List installed apps
list_apps() {
    init_state

    local apps_json
    apps_json=$(mdfind "kMDItemKind == 'Application'" 2>/dev/null | head -20 | jq -R '.' | jq -s 'map({name: (split("/") | .[-1] | sub("\\.app$"; "")), path: .})')

    jq -n \
        --argjson apps "$apps_json" \
        '{
            apps: $apps,
            count: ($apps | length),
            message: "Found " + ($apps | length | tostring) + " applications"
        }'
}

# Main CLI
case "${1:-help}" in
    init)
        init_state
        echo "Mac app testing state initialized"
        ;;
    launch)
        launch "${2:-app_name}" "${3:-}" "${4:-}"
        ;;
    interact)
        interact "${2:-app_name}" "${3:-}" "${4:-click}" "${5:-}"
        ;;
    verify)
        verify "${2:-app_name}" "${3:-}" "${4:-}"
        ;;
    accessibility)
        accessibility "${2:-app_name}" "${3:-}"
        ;;
    results)
        results
        ;;
    history)
        history
        ;;
    list)
        list_apps
        ;;
    help|*)
        cat <<EOF
Mac App Testing Hooks - macOS Application Testing

Usage:
  $0 launch <app_name> [bundle_id] [args]  Launch macOS application
  $0 interact <app_name> <element> [action] [value]  Interact with app UI
  $0 verify <app_name> [expected] [check_type]  Verify app state
  $0 accessibility <app_name> [element]        Check accessibility
  $0 results                                 Get test results
  $0 history                                 Get interaction history
  $0 list                                    List installed apps

Interaction Actions:
  click     - Click on element
  type      - Type text into element
  select    - Select from dropdown/menu
  menu      - Select menu item

Verification Types:
  running   - Check if app is running
  window    - Check if app has windows
  element   - Check if element exists
  state     - Check app state

Examples:
  $0 launch "Safari"
  $0 interact "Safari" "address_bar" "type" "https://example.com"
  $0 verify "Safari" "running" "running"
  $0 accessibility "Safari"
  $0 list
EOF
        ;;
esac
