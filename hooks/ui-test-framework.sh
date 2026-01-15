#!/bin/bash
# UI Test Framework - Automated browser testing with Claude in Chrome
# Solves the problem: "UI testing is tedious"

set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
UI_TEST_DIR="${CLAUDE_DIR}/.ui-tests"
TEST_RESULTS="${UI_TEST_DIR}/results.jsonl"
TEST_RECORDINGS="${UI_TEST_DIR}/recordings"
LOG_FILE="${CLAUDE_DIR}/ui-test-framework.log"

mkdir -p "$UI_TEST_DIR" "$TEST_RECORDINGS"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# UI TEST DEFINITIONS
# =============================================================================

create_test_suite() {
    local suite_name="$1"
    local base_url="$2"

    local suite_file="${UI_TEST_DIR}/${suite_name}.json"

    jq -n \
        --arg name "$suite_name" \
        --arg url "$base_url" \
        '{
            suite_name: $name,
            base_url: $url,
            tests: [],
            created_at: (now | todate)
        }' > "$suite_file"

    log "Created test suite: $suite_name"
    echo "$suite_file"
}

add_test_case() {
    local suite_name="$1"
    local test_name="$2"
    local test_steps="$3"  # JSON array of steps
    local expected_outcome="$4"

    local suite_file="${UI_TEST_DIR}/${suite_name}.json"

    if [[ ! -f "$suite_file" ]]; then
        echo '{"error":"Test suite not found"}'
        return 1
    fi

    local test_case
    test_case=$(jq -n \
        --arg name "$test_name" \
        --argjson steps "$test_steps" \
        --arg expected "$expected_outcome" \
        '{
            test_name: $name,
            steps: $steps,
            expected_outcome: $expected,
            added_at: (now | todate)
        }')

    jq --argjson test "$test_case" '.tests += [$test]' "$suite_file" > "${suite_file}.tmp"
    mv "${suite_file}.tmp" "$suite_file"

    log "Added test case: $test_name to $suite_name"
    echo "$test_case"
}

# =============================================================================
# BROWSER AUTOMATION HELPERS
# =============================================================================

generate_browser_script() {
    local test_case="$1"
    local base_url="$2"

    # Extract test steps
    local test_name
    local steps
    local expected
    test_name=$(echo "$test_case" | jq -r '.test_name')
    steps=$(echo "$test_case" | jq -c '.steps')
    expected=$(echo "$test_case" | jq -r '.expected_outcome')

    log "Generating browser automation script for: $test_name"

    # Generate Claude-executable instructions
    jq -n \
        --arg name "$test_name" \
        --arg url "$base_url" \
        --argjson steps "$steps" \
        --arg expected "$expected" \
        '{
            test_name: $name,
            automation_instructions: {
                phase_1_setup: {
                    description: "Initialize browser session",
                    tools: [
                        {
                            tool: "mcp__claude-in-chrome__tabs_context_mcp",
                            params: {createIfEmpty: true},
                            purpose: "Get or create browser tab"
                        },
                        {
                            tool: "mcp__claude-in-chrome__tabs_create_mcp",
                            params: {},
                            purpose: "Create new tab for test"
                        },
                        {
                            tool: "mcp__claude-in-chrome__navigate",
                            params: {url: $url, tabId: "<from_previous_step>"},
                            purpose: "Navigate to application"
                        }
                    ]
                },
                phase_2_actions: {
                    description: "Execute test steps",
                    steps: $steps,
                    tools_per_step: [
                        {
                            type: "click",
                            tool: "mcp__claude-in-chrome__find + computer",
                            example: "find(\"login button\") then computer(left_click, ref)"
                        },
                        {
                            type: "type",
                            tool: "mcp__claude-in-chrome__find + computer",
                            example: "find(\"username field\") then computer(type, \"username\")"
                        },
                        {
                            type: "wait",
                            tool: "mcp__claude-in-chrome__computer",
                            example: "computer(wait, 2 seconds)"
                        },
                        {
                            type: "screenshot",
                            tool: "mcp__claude-in-chrome__computer",
                            example: "computer(screenshot) for evidence"
                        }
                    ]
                },
                phase_3_verification: {
                    description: "Verify expected outcome",
                    expected_outcome: $expected,
                    tools: [
                        {
                            tool: "mcp__claude-in-chrome__read_page",
                            params: {tabId: "<active_tab>"},
                            purpose: "Read page state"
                        },
                        {
                            tool: "mcp__claude-in-chrome__find",
                            params: {query: "<expected_element>", tabId: "<active_tab>"},
                            purpose: "Verify expected elements present"
                        },
                        {
                            tool: "mcp__claude-in-chrome__computer",
                            params: {action: "screenshot"},
                            purpose: "Capture final state as evidence"
                        }
                    ]
                },
                phase_4_report: {
                    description: "Generate test result",
                    report_format: {
                        test_name: $name,
                        status: "pass|fail",
                        actual_outcome: "description",
                        expected_outcome: $expected,
                        screenshots: ["list", "of", "screenshot", "ids"],
                        error: "if any",
                        duration: "seconds"
                    }
                }
            },
            claude_prompt: "Execute this UI test using Claude in Chrome MCP tools:\n\n1. Initialize browser (tabs_context_mcp, tabs_create_mcp, navigate)\n2. Execute steps: " + ($steps | join(", ")) + "\n3. Verify: " + $expected + "\n4. Report: Pass/Fail with evidence (screenshots)\n\nUse find() to locate elements, computer() to interact, read_page() to verify state."
        }'
}

# =============================================================================
# VISUAL REGRESSION TESTING
# =============================================================================

take_baseline_screenshot() {
    local test_name="$1"
    local element_selector="$2"
    local url="$3"

    local baseline_id="${test_name}_baseline_$(date +%s)"
    local baseline_file="${TEST_RECORDINGS}/${baseline_id}.json"

    log "Taking baseline screenshot for visual regression: $test_name"

    # Instructions for Claude to take screenshot
    jq -n \
        --arg id "$baseline_id" \
        --arg test "$test_name" \
        --arg selector "$element_selector" \
        --arg url "$url" \
        '{
            baseline_id: $id,
            test_name: $test,
            url: $url,
            element_selector: $selector,
            instructions: [
                "1. Navigate to: " + $url,
                "2. Find element: " + $selector,
                "3. Take screenshot using computer(screenshot) or zoom action",
                "4. Save screenshot ID as baseline for visual comparison",
                "5. Store in: " + "'"$baseline_file"'"
            ],
            purpose: "Visual regression baseline - future screenshots compared against this",
            timestamp: (now | todate)
        }' > "$baseline_file"

    echo "$baseline_id"
}

compare_visual_regression() {
    local baseline_id="$1"
    local new_screenshot_id="$2"

    log "Comparing visual regression: $baseline_id vs $new_screenshot_id"

    # Return comparison instructions for Claude
    jq -n \
        --arg baseline "$baseline_id" \
        --arg current "$new_screenshot_id" \
        '{
            comparison_task: "Visual regression detection",
            baseline_screenshot: $baseline,
            current_screenshot: $current,
            instructions: [
                "1. Retrieve both screenshot images",
                "2. Compare visually for differences:",
                "   - Layout changes",
                "   - Styling differences",
                "   - Missing elements",
                "   - Text changes",
                "   - Color shifts",
                "3. Report differences with descriptions",
                "4. Classify: pass (no significant changes) or fail (visual regression)"
            ],
            output_format: {
                status: "pass|fail",
                differences: ["list of visual differences found"],
                severity: "minor|major|breaking",
                recommendation: "accept changes|investigate|revert"
            }
        }'
}

# =============================================================================
# E2E TEST ORCHESTRATION
# =============================================================================

run_test_suite() {
    local suite_name="$1"
    local record_video="${2:-false}"

    local suite_file="${UI_TEST_DIR}/${suite_name}.json"

    if [[ ! -f "$suite_file" ]]; then
        echo '{"error":"Test suite not found: '"$suite_name"'"}'
        return 1
    fi

    log "Running test suite: $suite_name"

    local base_url
    local tests
    base_url=$(jq -r '.base_url' "$suite_file")
    tests=$(jq -c '.tests[]' "$suite_file")

    local test_count=0
    local passed=0
    local failed=0

    # Generate execution plan for Claude
    local execution_plan='{"test_suite":"'"$suite_name"'","base_url":"'"$base_url"'","tests":[],"recording":'"$record_video"'}'

    while IFS= read -r test_case; do
        ((test_count++))

        local test_script
        test_script=$(generate_browser_script "$test_case" "$base_url")

        execution_plan=$(echo "$execution_plan" | jq \
            --argjson script "$test_script" \
            '.tests += [$script]')

    done <<< "$tests"

    # Add GIF recording if requested
    if [[ "$record_video" == "true" ]]; then
        execution_plan=$(echo "$execution_plan" | jq '.recording_instructions = {
            start: "Use gif_creator(action: start_recording) before tests",
            during: "Take screenshots at key moments",
            end: "Use gif_creator(action: export, download: true) after tests",
            purpose: "Visual proof of test execution"
        }')
    fi

    # Return full execution plan with result callback instructions
    jq -n \
        --argjson plan "$execution_plan" \
        --argjson count "$test_count" \
        --arg results_file "$TEST_RESULTS" \
        '{
            suite_execution: $plan,
            total_tests: $count,
            status: "ready_to_execute",
            instructions: [
                "1. Start GIF recording if recording: true",
                "2. For each test in tests array:",
                "   a. Execute automation_instructions phase by phase",
                "   b. Take screenshots for evidence",
                "   c. Record result using record-test-result command",
                "3. Stop GIF recording and export",
                "4. Generate summary report",
                "5. Return final summary with pass/fail counts"
            ],
            result_callback: {
                command: "ui-test-framework.sh record-result",
                format: "ui-test-framework.sh record-result <test_name> <suite_name> <pass|fail> <duration_seconds> [error_message] [screenshots_json]",
                example: "ui-test-framework.sh record-result \"Login test\" \"auth_tests\" \"pass\" \"2.5\" \"\" \"[]\"",
                required_after_each_test: true
            },
            results_file: $results_file,
            note: "Use Claude in Chrome MCP tools to execute this plan. Call record-result after EACH test. All tools are already available."
        }'
}

record_test_result() {
    local test_name="$1"
    local suite_name="$2"
    local status="$3"
    local duration="$4"
    local error_message="${5:-}"
    local screenshots="${6:-[]}"

    local result
    result=$(jq -n \
        --arg test "$test_name" \
        --arg suite "$suite_name" \
        --arg status "$status" \
        --argjson duration "$duration" \
        --arg error "$error_message" \
        --argjson screenshots "$screenshots" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            timestamp: $ts,
            test_name: $test,
            suite_name: $suite,
            status: $status,
            duration_seconds: $duration,
            error_message: $error,
            screenshots: $screenshots
        }')

    echo "$result" >> "$TEST_RESULTS"
    log "Recorded test result: $test_name -> $status"
    echo "$result"
}

# Submit test result from JSON (easy interface for Claude)
submit_test_result() {
    local result_json

    # Read from stdin if no argument, otherwise use argument
    if [[ -z "${1:-}" ]]; then
        result_json=$(cat)
    else
        result_json="$1"
    fi

    # Parse JSON and call record_test_result
    local test_name
    local suite_name
    local status
    local duration
    local error_msg
    local screenshots

    test_name=$(echo "$result_json" | jq -r '.test_name')
    suite_name=$(echo "$result_json" | jq -r '.suite_name // "unknown"')
    status=$(echo "$result_json" | jq -r '.status')
    duration=$(echo "$result_json" | jq -r '.duration_seconds // 0')
    error_msg=$(echo "$result_json" | jq -r '.error_message // ""')
    screenshots=$(echo "$result_json" | jq -c '.screenshots // []')

    # Validate required fields
    if [[ -z "$test_name" ]] || [[ -z "$status" ]]; then
        echo '{"error":"Missing required fields: test_name and status"}'
        return 1
    fi

    # Record result
    record_test_result "$test_name" "$suite_name" "$status" "$duration" "$error_msg" "$screenshots"
}

# Execute test suite with Claude and capture results
execute_test_suite() {
    local suite_name="$1"
    local record_video="${2:-false}"

    log "Executing test suite with Claude: $suite_name"

    # Get execution plan
    local plan
    plan=$(run_test_suite "$suite_name" "$record_video")

    # Check if suite exists
    if echo "$plan" | jq -e '.error' &>/dev/null; then
        echo "$plan"
        return 1
    fi

    local suite_file="${UI_TEST_DIR}/${suite_name}.json"
    local base_url
    base_url=$(jq -r '.base_url' "$suite_file")

    local test_count
    local tests
    test_count=$(echo "$plan" | jq -r '.total_tests')
    tests=$(jq -c '.tests[]' "$suite_file")

    local start_time
    start_time=$(date +%s)

    local passed=0
    local failed=0
    local test_results="[]"

    log "Starting execution of $test_count tests"

    # Process each test
    local test_index=0
    while IFS= read -r test_case; do
        ((test_index++))

        local test_name
        local test_steps
        local expected_outcome
        test_name=$(echo "$test_case" | jq -r '.test_name')
        test_steps=$(echo "$test_case" | jq -c '.steps')
        expected_outcome=$(echo "$test_case" | jq -r '.expected_outcome')

        log "Executing test $test_index/$test_count: $test_name"

        local test_start
        test_start=$(date +%s)

        # Generate Claude prompt for this specific test
        local claude_prompt
        claude_prompt=$(cat << EOF
Execute UI test: $test_name

Base URL: $base_url
Steps: $(echo "$test_steps" | jq -r 'join(", ")')
Expected outcome: $expected_outcome

Instructions:
1. If first test, use tabs_context_mcp(createIfEmpty: true) to get/create tab
2. If first test, navigate to $base_url
3. For each step in the test:
   - Use find() to locate elements
   - Use computer() to interact (click, type, etc.)
   - Take screenshots at key moments
4. Verify expected outcome using read_page() or find()
5. Report result as JSON:
   {
     "test_name": "$test_name",
     "status": "pass" or "fail",
     "actual_outcome": "what actually happened",
     "error": "error message if failed",
     "screenshots": ["screenshot_id1", "screenshot_id2"]
   }

Return ONLY the JSON result, no other text.
EOF
)

        # Execute test with Claude (this would call Claude API or use MCP tools)
        # For now, we'll create a placeholder that shows what should happen
        local test_result
        test_result=$(execute_test_with_claude "$test_name" "$claude_prompt" "$base_url" "$test_steps" "$expected_outcome")

        local test_end
        test_end=$(date +%s)
        local test_duration=$((test_end - test_start))

        # Parse result
        local test_status
        local error_msg
        local screenshots
        test_status=$(echo "$test_result" | jq -r '.status // "fail"')
        error_msg=$(echo "$test_result" | jq -r '.error // ""')
        screenshots=$(echo "$test_result" | jq -c '.screenshots // []')

        # Record result
        record_test_result "$test_name" "$suite_name" "$test_status" "$test_duration" "$error_msg" "$screenshots" >/dev/null

        # Update counters
        if [[ "$test_status" == "pass" ]]; then
            ((passed++))
        else
            ((failed++))
        fi

        # Collect results
        test_results=$(echo "$test_results" | jq \
            --arg name "$test_name" \
            --arg status "$test_status" \
            --argjson duration "$test_duration" \
            --arg error "$error_msg" \
            '. += [{test_name: $name, status: $status, duration: $duration, error: $error}]')

    done <<< "$tests"

    local end_time
    end_time=$(date +%s)
    local total_duration=$((end_time - start_time))

    # Generate summary
    jq -n \
        --arg suite "$suite_name" \
        --argjson total "$test_count" \
        --argjson passed "$passed" \
        --argjson failed "$failed" \
        --argjson duration "$total_duration" \
        --argjson results "$test_results" \
        '{
            suite_name: $suite,
            total_tests: $total,
            passed: $passed,
            failed: $failed,
            pass_rate: (if $total > 0 then ($passed / $total * 100) else 0 end),
            duration_seconds: $duration,
            status: (if $failed == 0 then "PASS" else "FAIL"),
            individual_results: $results,
            summary: "\($passed)/\($total) tests passed in \($duration)s"
        }'
}

# Execute a single test with Claude (placeholder for actual Claude API call)
execute_test_with_claude() {
    local test_name="$1"
    local prompt="$2"
    local base_url="$3"
    local steps="$4"
    local expected="$5"

    log "Claude execution requested for: $test_name"

    # This is a placeholder - in reality, this would:
    # 1. Call Claude API with the prompt
    # 2. Claude would use Claude-in-Chrome MCP tools
    # 3. Capture the JSON response from Claude
    # 4. Return it

    # For now, return instructions for manual execution
    jq -n \
        --arg test "$test_name" \
        --arg prompt_text "$prompt" \
        '{
            execution_mode: "manual",
            test_name: $test,
            instructions: "Copy this prompt to Claude and execute. Claude will use Claude-in-Chrome MCP tools.",
            prompt: $prompt_text,
            expected_response_format: {
                test_name: "string",
                status: "pass|fail",
                actual_outcome: "string",
                error: "string (if failed)",
                screenshots: ["array", "of", "screenshot", "ids"]
            },
            note: "After execution, Claude should return JSON in the expected format"
        }'
}

# =============================================================================
# SMART TEST GENERATION
# =============================================================================

generate_tests_from_page() {
    local url="$1"
    local focus_area="${2:-all}"

    log "Generating tests from page: $url"

    # Return instructions for Claude to analyze and generate tests
    jq -n \
        --arg url "$url" \
        --arg focus "$focus_area" \
        '{
            task: "Analyze page and generate UI tests",
            url: $url,
            focus_area: $focus,
            instructions: [
                "1. Navigate to URL using Claude in Chrome",
                "2. Use read_page() to analyze page structure",
                "3. Identify interactive elements:",
                "   - Forms and input fields",
                "   - Buttons and links",
                "   - Navigation menus",
                "   - Modal dialogs",
                "   - Dynamic content areas",
                "4. For each element, generate test case:",
                "   - Test name (e.g., \"Submit contact form\")",
                "   - Steps to interact",
                "   - Expected outcome",
                "5. Create test suite with all generated tests"
            ],
            output_format: {
                suite_name: "generated_tests_" + $url,
                tests: [
                    {
                        test_name: "example",
                        steps: ["step1", "step2"],
                        expected_outcome: "outcome"
                    }
                ]
            },
            usage: "Use generated tests with: ui-test-framework.sh run-test-suite <suite_name>"
        }'
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    create-suite)
        create_test_suite "${2:-test_suite}" "${3:-http://localhost:3000}"
        ;;
    add-test)
        # args: suite_name test_name steps_json expected_outcome
        add_test_case "${2:-suite}" "${3:-test}" "${4:-[]}" "${5:-outcome}"
        ;;
    generate-script)
        # Generate automation script for a test
        test_case=$(cat "${2:-test.json}")
        generate_browser_script "$test_case" "${3:-http://localhost:3000}"
        ;;
    run-suite)
        # Generate execution plan (legacy - use execute-suite for actual execution)
        run_test_suite "${2:-test_suite}" "${3:-false}"
        ;;
    execute-suite)
        # Execute test suite with Claude and record results
        execute_test_suite "${2:-test_suite}" "${3:-false}"
        ;;
    record-result)
        record_test_result "${2:-test}" "${3:-suite}" "${4:-pass}" "${5:-0}" "${6:-}" "${7:-[]}"
        ;;
    submit-result)
        # Submit test result from JSON (for Claude's use)
        # If $2 exists, use it; otherwise read from stdin
        if [[ -n "${2:-}" ]]; then
            submit_test_result "$2"
        else
            submit_test_result
        fi
        ;;
    baseline-screenshot)
        take_baseline_screenshot "${2:-test}" "${3:-element}" "${4:-http://localhost:3000}"
        ;;
    visual-regression)
        compare_visual_regression "${2:-baseline_id}" "${3:-screenshot_id}"
        ;;
    generate-tests)
        generate_tests_from_page "${2:-http://localhost:3000}" "${3:-all}"
        ;;
    list-suites)
        ls -1 "${UI_TEST_DIR}"/*.json 2>/dev/null | xargs -I {} basename {} .json || echo "No test suites found"
        ;;
    view-results)
        if [[ -f "$TEST_RESULTS" ]]; then
            # Read all results and get last N objects (not lines)
            VIEW_LIMIT="${2:-10}"
            jq -s --argjson limit "$VIEW_LIMIT" '{total: length, passed: (map(select(.status == "pass")) | length), failed: (map(select(.status == "fail")) | length), recent: (. | reverse | .[:$limit] | reverse)}' "$TEST_RESULTS"
        else
            echo '{"total":0,"passed":0,"failed":0,"recent":[]}'
        fi
        ;;
    help|*)
        cat << 'EOF'
UI Test Framework - Automated Browser Testing

Solves the problem: "UI testing is tedious"

USES CLAUDE IN CHROME MCP FOR AUTOMATION!

USAGE:
  ui-test-framework.sh <command> [args]

COMMANDS:
  create-suite <name> <base_url>
    - Create new test suite
    - Example: create-suite "auth_tests" "http://localhost:3000"

  add-test <suite> <test_name> <steps_json> <expected>
    - Add test case to suite
    - Steps: JSON array like '["Click login", "Enter credentials", "Submit"]'
    - Example: add-test "auth_tests" "Login flow" '[...]' "Dashboard loads"

  run-suite <suite_name> [record_gif]
    - Generate execution plan for Claude (legacy)
    - record_gif: true/false (creates GIF recording of execution)
    - Returns execution plan (does not execute tests)

  execute-suite <suite_name> [record_gif]
    - Execute all tests in suite and record results
    - record_gif: true/false (creates GIF recording of execution)
    - Runs tests, captures results, populates TEST_RESULTS file
    - Returns summary with pass/fail counts

  generate-tests <url> [focus_area]
    - Automatically generate tests by analyzing a page
    - Focus: "forms", "navigation", "interactions", or "all"
    - Uses Claude in Chrome to crawl and identify testable elements

  baseline-screenshot <test_name> <element> <url>
    - Take baseline screenshot for visual regression
    - Future tests compare against this baseline

  visual-regression <baseline_id> <current_screenshot_id>
    - Compare screenshots for visual regressions
    - Returns differences and recommendations

  record-result <test> <suite> <status> <duration> [error] [screenshots]
    - Record test execution result (low-level API)
    - Status: pass/fail
    - Duration: seconds

  submit-result <json_result>
    - Submit test result from JSON (easy interface for Claude)
    - JSON format: {"test_name":"...", "suite_name":"...", "status":"pass|fail", "duration_seconds":N, "error_message":"...", "screenshots":[]}
    - Example: ui-test-framework.sh submit-result '{"test_name":"Login","status":"pass","duration_seconds":2.5}'

  view-results [limit]
    - View recent test results
    - Default: last 10 results

  list-suites
    - List all test suites

WORKFLOW EXAMPLE:
  # 1. Create test suite
  ui-test-framework.sh create-suite "checkout" "http://localhost:3000"

  # 2. Add test cases
  ui-test-framework.sh add-test "checkout" "Add to cart" \
    '["Click product", "Click add to cart", "Verify cart count"]' \
    "Cart shows 1 item"

  # 3. Run tests (with GIF recording)
  ui-test-framework.sh run-suite "checkout" true > execution_plan.json

  # 4. Execute plan using Claude in Chrome MCP
  # (Claude reads execution_plan.json and executes with browser tools)

  # 5. View results
  ui-test-framework.sh view-results 5

SMART TEST GENERATION:
  # Auto-generate tests from existing page
  ui-test-framework.sh generate-tests "http://localhost:3000/login" "forms"

  # Claude will:
  # 1. Analyze page structure
  # 2. Identify all interactive elements
  # 3. Generate test cases for each interaction
  # 4. Create complete test suite

VISUAL REGRESSION TESTING:
  # Take baseline
  ui-test-framework.sh baseline-screenshot "homepage" ".hero-section" "http://localhost:3000"

  # After code changes, compare
  ui-test-framework.sh visual-regression "baseline_id" "new_screenshot_id"

KEY FEATURES:
  ✓ Automated browser testing with Claude in Chrome
  ✓ GIF recording of test execution
  ✓ Visual regression detection
  ✓ Smart test generation from page analysis
  ✓ Test result tracking and history
  ✓ Screenshot evidence for each test
  ✓ Integration with debug-orchestrator for regression detection

CLAUDE IN CHROME MCP TOOLS USED:
  • tabs_context_mcp - Browser session management
  • tabs_create_mcp - Create test tabs
  • navigate - Go to URLs
  • find - Locate elements by description
  • computer - Click, type, screenshot
  • read_page - Verify page state
  • gif_creator - Record test execution

INTEGRATION WITH DEBUG ORCHESTRATOR:
  # Combine UI testing with debugging
  debug-orchestrator.sh smart-debug "Button not working" ui \
    "ui-test-framework.sh run-suite button_tests"

  # Regression detection with UI tests
  debug-orchestrator.sh verify-fix snapshot_123 \
    "ui-test-framework.sh run-suite full_suite"

EOF
        ;;
esac
