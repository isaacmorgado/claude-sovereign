#!/usr/bin/env bash
#
# Test Runner for Claude Autonomous System
# Executes all test suites and provides consolidated results
#

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

# Colors for output
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[1;33m'
readonly BLUE='\033[0;34m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m' # No Color

# Test suite files
declare -a TEST_SUITES=(
    "test-memory-manager.sh"
    "test-auto-continue.sh"
    "test-swarm-orchestrator.sh"
    "test-coordinator-e2e.sh"
)

# Results tracking
declare -a SUITE_NAMES=()
declare -a SUITE_PASSED=()
declare -a SUITE_FAILED=()
declare -a SUITE_TOTAL=()
declare -a SUITE_DURATION=()
declare -a SUITE_STATUS=()

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_TESTS=0
START_TIME=$(date +%s)

# ============================================================================
# Helper Functions
# ============================================================================

log_header() {
    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║     CLAUDE AUTONOMOUS SYSTEM - TEST SUITE RUNNER              ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    echo -e "  Date: $(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "  Suites: ${#TEST_SUITES[@]}"
    echo ""
}

run_suite() {
    local suite_file="$1"
    local suite_name="${suite_file%.sh}"
    suite_name="${suite_name#test-}"

    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${BLUE}  Running: $suite_file${NC}"
    echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"

    local suite_start=$(date +%s)
    local suite_output
    local suite_exit_code=0

    # Run the test suite and capture output
    if suite_output=$(./"$suite_file" 2>&1); then
        suite_exit_code=0
    else
        suite_exit_code=$?
    fi

    local suite_end=$(date +%s)
    local duration=$((suite_end - suite_start))

    # Parse results from output
    # Look for lines like "  Passed: X" and "  Failed: Y"
    local passed_line=$(echo "$suite_output" | grep -E "Passed: [0-9]+" | tail -1 || echo "")
    local failed_line=$(echo "$suite_output" | grep -E "Failed: [0-9]+" | tail -1 || echo "")

    # Extract just the number after "Passed:" or "Failed:"
    local passed=$(echo "$passed_line" | sed 's/.*Passed: *//' | grep -oE "^[0-9]+" | head -1 || echo "0")
    local failed=$(echo "$failed_line" | sed 's/.*Failed: *//' | grep -oE "^[0-9]+" | head -1 || echo "0")

    # Ensure we have valid numbers
    passed=${passed:-0}
    failed=${failed:-0}
    if ! [[ "$passed" =~ ^[0-9]+$ ]]; then passed=0; fi
    if ! [[ "$failed" =~ ^[0-9]+$ ]]; then failed=0; fi

    local total=$((passed + failed))

    # Store results
    SUITE_NAMES+=("$suite_name")
    SUITE_PASSED+=("$passed")
    SUITE_FAILED+=("$failed")
    SUITE_TOTAL+=("$total")
    SUITE_DURATION+=("$duration")

    if [[ $failed -eq 0 && $suite_exit_code -eq 0 ]]; then
        SUITE_STATUS+=("PASS")
        echo -e "  ${GREEN}✓ Suite completed: $passed passed, $failed failed (${duration}s)${NC}"
    else
        SUITE_STATUS+=("FAIL")
        echo -e "  ${RED}✗ Suite failed: $passed passed, $failed failed (${duration}s)${NC}"
        echo ""
        echo -e "${YELLOW}  Output:${NC}"
        echo "$suite_output" | head -50
    fi

    # Update totals
    TOTAL_PASSED=$((TOTAL_PASSED + passed))
    TOTAL_FAILED=$((TOTAL_FAILED + failed))
    TOTAL_TESTS=$((TOTAL_TESTS + total))

    echo ""
    return $suite_exit_code
}

print_summary() {
    local end_time=$(date +%s)
    local total_duration=$((end_time - START_TIME))

    echo ""
    echo -e "${CYAN}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${CYAN}║                    CONSOLIDATED RESULTS                       ║${NC}"
    echo -e "${CYAN}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""

    # Suite-by-suite breakdown
    echo -e "  ${BLUE}Suite Results:${NC}"
    echo -e "  ─────────────────────────────────────────────────────────"

    for i in "${!SUITE_NAMES[@]}"; do
        local name="${SUITE_NAMES[$i]}"
        local passed="${SUITE_PASSED[$i]}"
        local failed="${SUITE_FAILED[$i]}"
        local total="${SUITE_TOTAL[$i]}"
        local duration="${SUITE_DURATION[$i]}"
        local status="${SUITE_STATUS[$i]}"

        if [[ "$status" == "PASS" ]]; then
            printf "  ${GREEN}✓${NC} %-25s %3d/%3d passed (${duration}s)\n" "$name" "$passed" "$total"
        else
            printf "  ${RED}✗${NC} %-25s %3d/%3d passed, ${RED}%d failed${NC} (${duration}s)\n" "$name" "$passed" "$total" "$failed"
        fi
    done

    echo ""
    echo -e "  ─────────────────────────────────────────────────────────"

    # Overall summary
    if [[ $TOTAL_FAILED -eq 0 ]]; then
        echo -e "  ${GREEN}█████████████████████████████████████████████████████████████${NC}"
        echo -e "  ${GREEN}                    ALL TESTS PASSED!                        ${NC}"
        echo -e "  ${GREEN}█████████████████████████████████████████████████████████████${NC}"
    else
        echo -e "  ${RED}█████████████████████████████████████████████████████████████${NC}"
        echo -e "  ${RED}                    SOME TESTS FAILED                         ${NC}"
        echo -e "  ${RED}█████████████████████████████████████████████████████████████${NC}"
    fi

    echo ""
    echo -e "  Total Tests:  $TOTAL_TESTS"
    echo -e "  ${GREEN}Passed:       $TOTAL_PASSED${NC}"
    echo -e "  ${RED}Failed:       $TOTAL_FAILED${NC}"
    echo -e "  Duration:     ${total_duration}s"
    echo ""

    # Return appropriate exit code
    if [[ $TOTAL_FAILED -gt 0 ]]; then
        return 1
    fi
    return 0
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    log_header

    local any_failed=0

    for suite in "${TEST_SUITES[@]}"; do
        if [[ -f "$suite" && -x "$suite" ]]; then
            run_suite "$suite" || any_failed=1
        else
            echo -e "${YELLOW}⚠ Suite not found or not executable: $suite${NC}"
            SUITE_NAMES+=("${suite%.sh}")
            SUITE_PASSED+=(0)
            SUITE_FAILED+=(0)
            SUITE_TOTAL+=(0)
            SUITE_DURATION+=(0)
            SUITE_STATUS+=("SKIP")
        fi
    done

    print_summary

    exit $any_failed
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
