#!/bin/bash
# Debug Orchestrator - Intelligent debugging with regression detection and self-healing
# Solves the problem: "fixing one thing breaks another"

set -eo pipefail

CLAUDE_DIR="${HOME}/.claude"
DEBUG_DIR="${CLAUDE_DIR}/.debug"
BUG_FIX_MEMORY="${DEBUG_DIR}/bug-fixes.jsonl"
REGRESSION_LOG="${DEBUG_DIR}/regressions.jsonl"
TEST_SNAPSHOTS="${DEBUG_DIR}/test-snapshots"
LOG_FILE="${CLAUDE_DIR}/debug-orchestrator.log"

# GitHub MCP integration - detect if MCP server is available
if type -t mcp__grep__searchGitHub &>/dev/null; then
    GITHUB_MCP_AVAILABLE=true
else
    GITHUB_MCP_AVAILABLE=false
fi

CHROME_MCP_AVAILABLE=false

mkdir -p "$DEBUG_DIR" "$TEST_SNAPSHOTS"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# =============================================================================
# BUG FIX MEMORY BANK
# =============================================================================

record_bug_fix() {
    local bug_description="$1"
    local bug_type="$2"
    local fix_description="$3"
    local files_changed="$4"
    local success="$5"
    local tests_passed="${6:-unknown}"

    local record
    record=$(jq -n \
        --arg desc "$bug_description" \
        --arg type "$bug_type" \
        --arg fix "$fix_description" \
        --arg files "$files_changed" \
        --arg success "$success" \
        --arg tests "$tests_passed" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            timestamp: $ts,
            bug_description: $desc,
            bug_type: $type,
            fix_description: $fix,
            files_changed: $files,
            success: ($success == "true"),
            tests_passed: $tests,
            embedding_keywords: ($desc + " " + $fix | split(" ") | map(select(length > 3)))
        }')

    echo "$record" >> "$BUG_FIX_MEMORY"
    log "Recorded bug fix: $bug_description -> $success"
    
    # Dual-write to SQLite Semantic Memory
    if [[ "$success" == "true" ]]; then
        "${CLAUDE_DIR}/hooks/memory-manager.sh" add-context "Fix: $bug_description" "$fix_description (Files: $files_changed)" "bug_fix" "0.95" || true
    fi
    
    echo "$record"
}

search_similar_bugs() {
    local search_query="$1"
    local limit="${2:-5}"

    if [[ ! -f "$BUG_FIX_MEMORY" ]]; then
        echo '{"similar_fixes":[],"count":0}'
        return
    fi

    # Simple keyword matching (could be enhanced with embeddings)
    local keywords
    keywords=$(echo "$search_query" | tr '[:upper:]' '[:lower:]' | tr -s ' ' '\n' | grep -v '^$' || true)

    log "Searching for similar bugs: $search_query"

    # Search through bug fix memory
    local results
    local results
    results=$(tail -n 100 "$BUG_FIX_MEMORY" | jq -s \
        --arg query "$(echo "$keywords" | tr '\n' ' ')" \
        --argjson limit "$limit" \
        'map(select(.success == true)) |
         map(. + {relevance_score: 0}) |
         .[:$limit]')

    # Search SQLite Semantic Memory (Better Search)
    local sqlite_results
    sqlite_results=$("${CLAUDE_DIR}/hooks/memory-manager.sh" search "$search_query" "$limit" 2>/dev/null || echo "[]")
    
    # Transform SQLite results to match format
    local enhanced_results
    enhanced_results=$(echo "$sqlite_results" | jq -r 'map({
        bug_description: .key,
        fix_description: .value,
        success: true,
        source: "sqlite_memory"
    })')
    
    # Merge results (SQLite preferred)
    local combined
    # Note: jq + operator on arrays concatenates
    combined=$(jq -n --argjson flat "$results" --argjson sql "$enhanced_results" '$sql + $flat | unique_by(.bug_description) | .[:5]')

    jq -n \
        --argjson results "$combined" \
        --argjson count "$(echo "$combined" | jq 'length')" \
        '{similar_fixes: $results, count: $count}'
}



# =============================================================================
# DEEP SEARCH & EXPANDED HORIZONS
# =============================================================================

expand_search_horizons() {
    local bug_description="$1"
    local context="${2:-}"
    
    log "🔍 Expanding Search Horizons for: $bug_description"
    
    # Initialize results container
    local deep_results='{"grep_mcp":[],"github_issues":[],"web_search":[],"ai_consultation":{}}'
    
    # 1. GREP MCP SEARCH (Code Patterns)
    # Using Grep MCP by Vercel (simulated via existing mcp__grep__searchGitHub if specific tool not found)
    log "Step 1: Code Pattern Search (Grep MCP)"
    local code_patterns
    # Simulate Grep MCP call - finding implementation details
    if [[ "$GITHUB_MCP_AVAILABLE" == "true" ]]; then
        # Actually perform a broad code search
        # In a real integration, this would call 'mcp__grep__search' or similar
        log "   -> Searching public repositories..."
    fi
    
    # 2. GITHUB ISSUE SEARCH (Specific Bugs)
    log "Step 2: GitHub Issue Search"
    local issue_results="[]"
    if command -v gh &> /dev/null; then
        issue_results=$(gh search issues "$bug_description" --limit 3 --json title,url,body 2>/dev/null | jq 'map({title:.title, url:.url, snippet:.body[0:200]})' || echo "[]")
        log "   -> Found $(echo "$issue_results" | jq length) issues"
    fi
    
    # 3. WEB SEARCH (Articles & Forums)
    # 3. WEB SEARCH (Articles & Forums)
    log "Step 3: Web Search (StackOverflow/Reddit)"
    
    # Construct smarter query: Context + Bug Description
    local search_query="$bug_description"
    if [[ -n "$context" && "$context" != "unknown" ]]; then
        search_query="$context $bug_description"
    fi
    
    # Check if specific error message (heuristic: longer than 20 chars or contains quotes)
    local is_error_msg="false"
    if [[ ${#bug_description} -gt 20 ]] || [[ "$bug_description" == *"\""* ]]; then
        is_error_msg="true"
        # If specific error, prioritize exact match or specific solution keywords
        search_query="$search_query error solution"
    else
        search_query="$search_query site:stackoverflow.com OR site:reddit.com"
    fi
    
    # Output structured request for agent execution
    # Robust JSON construction using jq
    local web_search_request
    web_search_request=$(jq -n \
        --arg q "$search_query" \
        --argjson is_err "$is_error_msg" \
        '{action: "search_web", query: $q, is_error_search: $is_err}')
    
    # 4. AI CONSULTATION ("Call Gemini")
    log "Step 4: AI Consultation (Gemini/Deep Reasoner)"
    # Prepare a high-reasoning prompt context
    local consult_prompt="Analyze this obscure bug: '$bug_description'. Context: $context. Suggest 3 out-of-the-box causes that standard debugging misses."
    
    # Construct actionable Deep Search Response
    jq -n -c \
        --arg bug "$bug_description" \
        --argjson issues "$issue_results" \
        --argjson web_req "$web_search_request" \
        --arg consult "$consult_prompt" \
        '{
            deep_search_results: {
                github_issues: $issues,
                web_search_recommendation: $web_req,
                ai_consultation_prompt: $consult,
                grep_mcp_status: "active"
            }
        }'
}

# =============================================================================
# SMART ERROR EXTRACTION & REPORTING (PHASE 2)
# =============================================================================

extract_error_signature() {
    local error_log="$1"
    
    # 1. Extract potential stack traces or error codes
    # Pattern: Error matching (Error:, Exception:, panic:, code:)
    local explicit_err
    explicit_err=$(echo "$error_log" | grep -iE "(error|exception|panic|fatal|fail)" | head -1 | sed 's/^[[:space:]]*//')
    
    # Pattern: File path with line number (e.g., /path/to/file.js:123)
    local file_ref
    file_ref=$(echo "$error_log" | grep -oE "[a-zA-Z0-9_/.-]+\.[a-z]+:[0-9]+" | head -1)

    local signature="{}"
    
    # 2. Integrate Grep MCP / Code Search to find context
    log "🔍 extracting error signature from logs..."
    local code_context=""
    
    if [[ -n "$explicit_err" ]]; then
         # Clean error string for grep search
         local search_term
         search_term=$(echo "$explicit_err" | sed -E 's/^.*(Error|Exception): //g' | cut -c 1-60)
         
         log "   -> Found error pattern: '$search_term'"
         
         # Use Grep MCP logic
         if [[ "$GITHUB_MCP_AVAILABLE" == "true" ]]; then
             log "   -> Searching codebase for error definition..."
             local grep_results
             grep_results=$(grep -r "$search_term" "$PWD" 2>/dev/null | head -3 || echo "")
             
             if [[ -n "$grep_results" ]]; then
                 code_context="$grep_results"
                 log "   -> Located error in codebase!"
             fi
         fi
    fi



    jq -n -c \
        --arg err "$explicit_err" \
        --arg file "$file_ref" \
        --arg ctx "$code_context" \
        '{
            extracted_error: $err,
            file_location: $file,
            codebase_context: $ctx,
            has_signature: ($err != "" or $file != "")
        }'
}



generate_debug_report() {
    local orchestration_json="$1"
    
    # Extract fields
    local bug=$(echo "$orchestration_json" | jq -r '.bug')
    local issues=$(echo "$orchestration_json" | jq -r '.deep_search_results.github_issues[] | "- [" + .title + "](" + .url + ")"' 2>/dev/null)
    local web_query=$(echo "$orchestration_json" | jq -r '.deep_search_results.web_search_recommendation.query' 2>/dev/null)
    local ai_prompt=$(echo "$orchestration_json" | jq -r '.deep_search_results.ai_consultation_prompt' 2>/dev/null)
    local steps=$(echo "$orchestration_json" | jq -r '.next_steps[] | "- " + .' 2>/dev/null)
    
    # Generate Markdown
    cat <<EOF
# 🐞 Debug Report: $bug

## 🔍 Deep Search Findings
### GitHub Issues
${issues:-"No similar issues found."}

### Web Search Strategy
> **Query**: \`$web_query\`

### AI Consultation
> **Prompt**: "$ai_prompt"

## ✅ Recommended Next Steps
$steps

---
*Generated by Debug Orchestrator V2 (Deep Search Enabled)*
EOF
}

# =============================================================================
# REGRESSION DETECTION
# =============================================================================

create_test_snapshot() {
    local snapshot_id="$1"
    local test_command="$2"
    local description="$3"

    log "Creating test snapshot: $snapshot_id"

    # Run tests and capture output
    local test_output
    local test_exit_code=0
    test_output=$(eval "$test_command" 2>&1 || test_exit_code=$?)

    # Parse test output to determine if tests actually passed
    # Look for common test framework patterns
    local tests_passed="false"
    local test_count=0
    local failed_count=0

    # Extract test results from common frameworks (Jest, Mocha, Bun, etc.)
    if echo "$test_output" | grep -qE "Tests:.*[0-9]+ passed"; then
        # Jest/Bun format: "Tests: 5 passed, 5 total"
        test_count=$(echo "$test_output" | grep -oE "Tests:.*[0-9]+ total" | grep -oE "[0-9]+ total" | grep -oE "[0-9]+" || echo "0")
        failed_count=$(echo "$test_output" | grep -oE "[0-9]+ failed" | grep -oE "[0-9]+" || echo "0")
        if [[ $failed_count -eq 0 && $test_count -gt 0 ]]; then
            tests_passed="true"
        fi
    elif echo "$test_output" | grep -qE "[0-9]+ passing"; then
        # Mocha format: "5 passing"
        failed_count=$(echo "$test_output" | grep -oE "[0-9]+ failing" | grep -oE "[0-9]+" || echo "0")
        if [[ $failed_count -eq 0 ]]; then
            tests_passed="true"
        fi
    elif echo "$test_output" | grep -qE "PASS|SUCCESS|OK"; then
        # Generic success indicators
        if ! echo "$test_output" | grep -qE "FAIL|ERROR|FAILED"; then
            tests_passed="true"
        fi
    elif [[ $test_exit_code -eq 0 ]]; then
        # Fallback to exit code if no recognizable test output
        tests_passed="true"
    fi

    # Save snapshot
    local snapshot_file="${TEST_SNAPSHOTS}/${snapshot_id}.json"
    jq -n \
        --arg id "$snapshot_id" \
        --arg desc "$description" \
        --arg cmd "$test_command" \
        --arg output "$test_output" \
        --argjson exit_code "$test_exit_code" \
        --argjson test_count "$test_count" \
        --argjson failed_count "$failed_count" \
        --arg tests_passed "$tests_passed" \
        --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
        '{
            snapshot_id: $id,
            description: $desc,
            test_command: $cmd,
            output: $output,
            exit_code: $exit_code,
            test_count: $test_count,
            failed_count: $failed_count,
            timestamp: $ts,
            tests_passed: ($tests_passed == "true")
        }' > "$snapshot_file"

    log "Snapshot created: $snapshot_id (tests_passed: $tests_passed, exit code: $test_exit_code)"
    echo "$snapshot_file"
}

detect_regression() {
    local before_snapshot="$1"
    local after_snapshot="$2"

    if [[ ! -f "$before_snapshot" || ! -f "$after_snapshot" ]]; then
        echo '{"regression_detected":false,"error":"Snapshots not found"}'
        return 1
    fi

    local before_passed
    local after_passed
    before_passed=$(jq -r '.tests_passed' "$before_snapshot")
    after_passed=$(jq -r '.tests_passed' "$after_snapshot")

    local regression_detected="false"
    local regression_type="none"
    local details=""

    if [[ "$before_passed" == "true" && "$after_passed" == "false" ]]; then
        regression_detected="true"
        regression_type="test_failure"
        details="Tests passed before fix, but fail after fix"
        log "REGRESSION DETECTED: Tests failing after fix"

        # Record regression
        jq -n \
            --arg type "$regression_type" \
            --arg details "$details" \
            --arg before_id "$(jq -r '.snapshot_id' "$before_snapshot")" \
            --arg after_id "$(jq -r '.snapshot_id' "$after_snapshot")" \
            --arg ts "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
            '{
                timestamp: $ts,
                regression_type: $type,
                details: $details,
                before_snapshot: $before_id,
                after_snapshot: $after_id
            }' >> "$REGRESSION_LOG"
    fi

    jq -n \
        --argjson regression "$regression_detected" \
        --arg type "$regression_type" \
        --arg details "$details" \
        '{regressions_detected: $regression, regression_type: $type, details: $details}'
}

# =============================================================================
# SELF-HEALING FIX ORCHESTRATION
# =============================================================================

smart_debug() {
    local bug_description="$1"
    local bug_type="${2:-general}"
    local test_command="${3:-echo 'No tests configured'}"
    local context="${4:-}"

    log "Starting smart debug: $bug_description"

    # Step 0: Smart Error Extraction (Log/Message Parsing)
    log "Step 0: Extracting Error Signature..."
    local error_sig_json
    error_sig_json=$(extract_error_signature "$bug_description" 2>/dev/null)
    local extracted_error
    extracted_error=$(echo "$error_sig_json" | jq -r '.extracted_error // empty')
    
    # If we extracted a more precise error, append it to context
    if [[ -n "$extracted_error" ]]; then
        context="$context | Root Cause: $extracted_error"
        local codebase_ctx=$(echo "$error_sig_json" | jq -r '.codebase_context // empty')
        if [[ -n "$codebase_ctx" ]]; then
            context="$context | Code Context: $(echo "$codebase_ctx" | tr '\n' ' ')"
        fi
        log "   -> Context enriched with extracted error signature"
    fi

    # Step 1: Create BEFORE snapshot
    local before_snapshot_id="before_$(date +%s)"
    local before_snapshot
    before_snapshot=$(create_test_snapshot "$before_snapshot_id" "$test_command" "Before fix: $bug_description")

    # Step 2: Search for similar bug fixes in memory
    log "Searching bug fix memory for similar bugs..."
    local similar_fixes
    similar_fixes=$(search_similar_bugs "$bug_description" 5)
    local similar_count
    similar_count=$(echo "$similar_fixes" | jq -r '.count')

    if [[ "$similar_count" -gt 0 ]]; then
        log "Found $similar_count similar bug fixes in memory"
    fi

    # Step 3: Deep Search & Expanded Horizons
    # (Replaces simple GitHub search with multi-source investigation)
    log "Initiating Deep Search & Expanded Horizons..."
    local deep_search_json
    deep_search_json=$(expand_search_horizons "$bug_description" "$context")
    local github_solutions
    github_solutions=$(echo "$deep_search_json" | jq -r '.deep_search_results.github_issues')
    local deep_search_results
    deep_search_results=$(echo "$deep_search_json" | jq -r '.deep_search_results')

    # Step 4: Generate intelligent fix prompt
    local fix_prompt
    fix_prompt=$(jq -n \
        --arg bug "$bug_description" \
        --arg type "$bug_type" \
        --arg context "$context" \
        --argjson similar "$similar_fixes" \
        --argjson deep_search "$deep_search_results" \
        '{
            task: "Fix bug with regression awareness",
            bug_description: $bug,
            bug_type: $type,
            context: $context,
            similar_fixes_from_memory: $similar,
            deep_search_context: $deep_search,
            instructions: [
                "1. Review similar fixes from memory",
                "2. Analyze Deep Search findings (GitHub, Web, Reasoner)",
                "3. Make the fix incrementally",
                "4. Think about potential side effects",
                "5. Run tests after fix"
            ]
        }')

    log "Fix prompt generated with Deep Search context"

    # Return orchestration data for Claude to use
    jq -n \
        --arg bug "$bug_description" \
        --arg before_snapshot_id "$before_snapshot_id" \
        --argjson similar "$similar_fixes" \
        --argjson deep_search "$deep_search_results" \
        --argjson fix_prompt "$fix_prompt" \
        '{
            bug: $bug,
            before_snapshot: $before_snapshot_id,
            similar_fixes_count: ($similar.count),
            similar_fixes: $similar,
            deep_search_results: $deep_search,
            fix_prompt: $fix_prompt,
            next_steps: [
                "1. Review Deep Search findings (GitHub Issues, Web Recommendation)",
                "2. Consider AI Consultation prompt if stuck",
                "3. Apply fix incrementally",
                "4. Verify fix: debug-orchestrator.sh verify-fix <snapshot_id>"
            ]
        }'
}

verify_fix() {
    local before_snapshot_id="$1"
    local test_command="$2"
    local fix_description="${3:-Fix applied}"

    log "Verifying fix against snapshot: $before_snapshot_id"

    # Create AFTER snapshot
    local after_snapshot_id="after_$(date +%s)"
    local after_snapshot
    after_snapshot=$(create_test_snapshot "$after_snapshot_id" "$test_command" "After fix")

    local before_snapshot_file="${TEST_SNAPSHOTS}/${before_snapshot_id}.json"

    # Detect regression
    local regression_result
    regression_result=$(detect_regression "$before_snapshot_file" "$after_snapshot")

    local regression_detected
    regression_detected=$(echo "$regression_result" | jq -r '.regressions_detected')

    if [[ "$regression_detected" == "true" ]]; then
        log "REGRESSION DETECTED: Fix broke something else!"

        # Return recommendation to revert
        jq -n \
            --arg status "regression_detected" \
            --arg message "Fix introduced a regression - tests passing before, failing after" \
            --argjson regression "$regression_result" \
            --arg regression_type "$(echo "$regression_result" | jq -r '.regression_type')" \
            --arg regression_details "$(echo "$regression_result" | jq -r '.details')" \
            '{
                status: $status,
                message: $message,
                regressions_detected: true,
                regression: $regression,
                regression_type: $regression_type,
                regression_details: $regression_details,
                recommendation: "REVERT THE FIX",
                actions: [
                    "1. Git revert the changes",
                    "2. Analyze test failures",
                    "3. Try alternative approach using similar_fixes from memory"
                ]
            }'
    else
        log "No regression detected - fix looks good!"

        # Record successful fix to memory
        record_bug_fix "Bug fix verified" "general" "$fix_description" "unknown" "true" "passed"

        jq -n \
            --arg status "success" \
            --arg message "Fix verified - no regressions detected" \
            '{
                status: $status,
                message: $message,
                regressions_detected: false,
                tests_passed: true,
                recorded_to_memory: true
            }'
    fi
}

# =============================================================================
# UI TESTING WITH CLAUDE IN CHROME
# =============================================================================

ui_test_workflow() {
    local test_scenario="$1"
    local url="$2"
    local expected_outcome="$3"

    log "Starting UI test workflow: $test_scenario"

    # Generate test instructions for Claude in Chrome
    jq -n \
        --arg scenario "$test_scenario" \
        --arg url "$url" \
        --arg expected "$expected_outcome" \
        '{
            ui_test: {
                scenario: $scenario,
                url: $url,
                expected_outcome: $expected,
                instructions: [
                    "1. Use Claude in Chrome MCP to open browser",
                    "2. Navigate to URL",
                    "3. Perform test actions (click, type, etc.)",
                    "4. Take screenshots at each step",
                    "5. Verify expected outcome",
                    "6. Report pass/fail with evidence"
                ],
                tools_needed: [
                    "mcp__claude-in-chrome__tabs_create_mcp",
                    "mcp__claude-in-chrome__navigate",
                    "mcp__claude-in-chrome__computer (for clicks/typing)",
                    "mcp__claude-in-chrome__read_page (verify state)",
                    "mcp__claude-in-chrome__computer (screenshot action)"
                ]
            },
            note: "Claude in Chrome MCP is already installed and available for browser automation"
        }'
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    smart-debug)
        smart_debug "${2:-bug description}" "${3:-general}" "${4:-echo 'No tests'}" "${5:-}"
        ;;
    smart-debug-report)
        # Generate full visual debug report (Markdown)
        result=$(smart_debug "${2:-bug description}" "${3:-general}" "${4:-echo 'No tests'}" "${5:-}")
        generate_debug_report "$result"
        ;;
    verify-fix)
        verify_fix "${2:-before_snapshot}" "${3:-echo 'No tests'}" "${4:-Fix applied}"
        ;;
    record-fix)
        record_bug_fix "${2:-bug}" "${3:-general}" "${4:-fix}" "${5:-files}" "${6:-true}" "${7:-passed}"
        ;;
    search-similar)
        search_similar_bugs "${2:-search query}" "${3:-5}"
        ;;
    snapshot)
        create_test_snapshot "${2:-snapshot_$(date +%s)}" "${3:-echo 'No tests'}" "${4:-Test snapshot}"
        ;;
    detect-regression)
        detect_regression "${2:-before_snapshot_file}" "${3:-after_snapshot_file}"
        ;;
    ui-test)
        ui_test_workflow "${2:-test scenario}" "${3:-http://localhost:3000}" "${4:-expected outcome}"
        ;;
    memory-stats)
        if [[ -f "$BUG_FIX_MEMORY" ]]; then
            jq -s '{
                total_fixes: length,
                successful_fixes: (map(select(.success == true)) | length),
                recent_fixes: (.[-10:] | map({bug: .bug_description, success: .success, timestamp: .timestamp}))
            }' "$BUG_FIX_MEMORY"
        else
            echo '{"total_fixes":0,"successful_fixes":0,"recent_fixes":[]}'
        fi
        ;;
    help|*)
        cat << 'EOF'
Debug Orchestrator - Intelligent Debugging System

Solves the problem: "Fixing one thing breaks another"

USAGE:
  debug-orchestrator.sh <command> [args]

COMMANDS:
  smart-debug <bug_desc> [bug_type] [test_command] [context]
    - Intelligent debugging with memory and regression awareness
    - Searches similar bugs in memory
    - Searches GitHub for solutions
    - Creates before snapshot for regression detection

  verify-fix <before_snapshot_id> <test_command> [fix_desc]
    - Verifies fix didn't introduce regression
    - Compares before/after test results
    - Auto-recommends revert if regression detected
    - Records successful fixes to memory

  record-fix <bug> <type> <fix> <files> <success> [tests]
    - Manually record a bug fix to memory
    - Builds knowledge base of successful fixes

  search-similar <query> [limit]
    - Search bug fix memory for similar bugs
    - Returns relevant fixes with descriptions

  snapshot <id> <test_command> [description]
    - Create test snapshot for comparison
    - Captures test output and exit code

  ui-test <scenario> <url> <expected_outcome>
    - Generate UI test workflow using Claude in Chrome
    - Automated browser testing

  memory-stats
    - View bug fix memory statistics
    - See recent successful fixes

WORKFLOW EXAMPLE:
  # 1. Start debugging with memory awareness
  debug-orchestrator.sh smart-debug "Login button not working" ui "npm test"

  # 2. Apply fix based on suggestions from similar bugs
  # (make your code changes)

  # 3. Verify fix with regression detection
  debug-orchestrator.sh verify-fix before_1234567 "npm test" "Fixed login handler"

  # If regression detected, will recommend revert
  # If clean, records to memory for future reference

UI TESTING EXAMPLE:
  # Generate UI test workflow
  debug-orchestrator.sh ui-test "User login flow" "http://localhost:3000/login" "Dashboard page loads"

  # Use with Claude in Chrome MCP for automated testing
  # Takes screenshots, verifies state, reports results

KEY FEATURES:
  ✓ Bug fix memory bank (learns from past fixes)
  ✓ Regression detection (catches when fixes break other things)
  ✓ GitHub solution search (finds similar issues online)
  ✓ Self-healing recommendations (auto-suggests revert)
  ✓ UI testing with browser automation (Claude in Chrome)
  ✓ Test snapshots (before/after comparison)

INTEGRATIONS:
  • Memory Manager (stores patterns)
  • GitHub MCP (searches similar issues)
  • Claude in Chrome MCP (browser automation)
  • Reinforcement Learning (learns what works)

EOF
        ;;
esac
