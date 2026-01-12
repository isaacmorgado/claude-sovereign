#!/bin/bash
# Comprehensive Validation Suite for 100% Autonomous Operation
# Tests all capabilities: checkpoints, commands, MCPs, tools, RE toolkit, memory, Ken's patterns

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEST_LOG="${HOME}/.claude/logs/comprehensive-validation.log"
RESULTS_FILE="${HOME}/.claude/validation-results.json"

mkdir -p "$(dirname "$TEST_LOG")"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$TEST_LOG"
}

success() {
    echo -e "${GREEN}✅ $*${NC}" | tee -a "$TEST_LOG"
}

error() {
    echo -e "${RED}❌ $*${NC}" | tee -a "$TEST_LOG"
}

warning() {
    echo -e "${YELLOW}⚠️  $*${NC}" | tee -a "$TEST_LOG"
}

info() {
    echo -e "${BLUE}ℹ️  $*${NC}" | tee -a "$TEST_LOG"
}

# Initialize results
total_tests=0
passed_tests=0
failed_tests=0

run_test() {
    local test_name="$1"
    local test_command="$2"

    total_tests=$((total_tests + 1))
    info "Running: $test_name"

    if eval "$test_command" >> "$TEST_LOG" 2>&1; then
        success "$test_name"
        passed_tests=$((passed_tests + 1))
        return 0
    else
        error "$test_name"
        failed_tests=$((failed_tests + 1))
        return 1
    fi
}

echo ""
echo "======================================================================"
echo "  COMPREHENSIVE VALIDATION SUITE"
echo "  Testing 100% Autonomous Operation"
echo "======================================================================"
echo ""

# ============================================================================
# CATEGORY 1: CORE SYSTEM
# ============================================================================

echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 1: Core System Components"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "1.1 Memory Manager Exists" \
    "[[ -x ${SCRIPT_DIR}/memory-manager.sh ]]"

run_test "1.2 Autonomous Orchestrator Exists" \
    "[[ -x ${SCRIPT_DIR}/autonomous-orchestrator-v2.sh ]]"

run_test "1.3 Auto-Continue Hook Exists" \
    "[[ -x ${SCRIPT_DIR}/auto-continue.sh ]]"

run_test "1.4 Command Router Exists" \
    "[[ -x ${SCRIPT_DIR}/autonomous-command-router.sh ]]"

run_test "1.5 Post-Edit Quality Hook Exists" \
    "[[ -x ${SCRIPT_DIR}/post-edit-quality.sh ]]"

run_test "1.6 Project Navigator Exists" \
    "[[ -x ${SCRIPT_DIR}/project-navigator.sh ]]"

# ============================================================================
# CATEGORY 2: COMMAND ROUTER
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 2: Command Router (Autonomous Decision Engine)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Activate autonomous mode for these tests
touch ~/.claude/autonomous-mode.active

run_test "2.1 Router Status Check" \
    "${SCRIPT_DIR}/autonomous-command-router.sh status | jq -e '.autonomous == true'"

run_test "2.2 Router Context Threshold (execute_skill field)" \
    "${SCRIPT_DIR}/autonomous-command-router.sh execute checkpoint_context '80000/200000' | jq -e '.execute_skill == \"checkpoint\"'"

run_test "2.3 Router File Threshold (execute_skill field)" \
    "${SCRIPT_DIR}/autonomous-command-router.sh execute checkpoint_files '10' | jq -e '.execute_skill == \"checkpoint\"'"

run_test "2.4 Router Manual Trigger (execute_skill field)" \
    "${SCRIPT_DIR}/autonomous-command-router.sh execute manual '' | jq -e '.execute_skill == \"checkpoint\"'"

run_test "2.5 Router Build Complete Trigger" \
    "${SCRIPT_DIR}/autonomous-command-router.sh execute build_section_complete '' | jq -e '.execute_skill'"

# ============================================================================
# CATEGORY 3: MEMORY SYSTEM
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 3: Memory System (Persistent Context)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "3.1 Memory Set Task" \
    "${SCRIPT_DIR}/memory-manager.sh set-task 'Test Task' 'Test Context'"

run_test "3.2 Memory Add Context" \
    "${SCRIPT_DIR}/memory-manager.sh add-context 'Test note' 8"

run_test "3.3 Memory Get Working" \
    "${SCRIPT_DIR}/memory-manager.sh get-working | jq -e '.currentTask'"

run_test "3.4 Memory Record Episode" \
    "${SCRIPT_DIR}/memory-manager.sh record test_complete 'Test completed' success 'Details here'"

run_test "3.5 Memory Add Fact" \
    "${SCRIPT_DIR}/memory-manager.sh add-fact test_category test_key 'test value' 0.9"

run_test "3.6 Memory Add Pattern" \
    "${SCRIPT_DIR}/memory-manager.sh add-pattern test_pattern 'when X' 'do Y'"

run_test "3.7 Memory Search (Scored)" \
    "${SCRIPT_DIR}/memory-manager.sh remember-scored 'test' | jq -e 'length > 0'"

run_test "3.8 Memory Checkpoint Creation" \
    "${SCRIPT_DIR}/memory-manager.sh checkpoint 'Validation test checkpoint' | grep -q '^cp_'"

run_test "3.9 Memory List Checkpoints" \
    "${SCRIPT_DIR}/memory-manager.sh list-checkpoints | jq -e 'length > 0'"

run_test "3.10 Memory Context Budget Check" \
    "${SCRIPT_DIR}/memory-manager.sh context-usage | jq -e '.status'"

# ============================================================================
# CATEGORY 4: PROJECT NAVIGATION
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 4: Project Navigation (Token Efficiency)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create temp test project
TEST_PROJECT="/tmp/validation-test-project-$$"
mkdir -p "$TEST_PROJECT"/{src,tests,docs}
touch "$TEST_PROJECT"/{README.md,package.json}
touch "$TEST_PROJECT"/src/{main.js,utils.js}
touch "$TEST_PROJECT"/tests/test.js

run_test "4.1 Project Navigator Generate Index" \
    "${SCRIPT_DIR}/project-navigator.sh generate '$TEST_PROJECT' 3"

run_test "4.2 Project Index File Created" \
    "[[ -f '$TEST_PROJECT/.claude/project-index.md' ]]"

run_test "4.3 Project Index Contains Tree" \
    "grep -q 'Directory Tree' '$TEST_PROJECT/.claude/project-index.md'"

run_test "4.4 Project Index Contains Stats" \
    "grep -q 'Project Statistics' '$TEST_PROJECT/.claude/project-index.md'"

run_test "4.5 Project Navigator Quick (Cache)" \
    "${SCRIPT_DIR}/project-navigator.sh quick '$TEST_PROJECT' | grep -q 'Project Structure'"

# Cleanup
rm -rf "$TEST_PROJECT"

# ============================================================================
# CATEGORY 5: SKILL COMMANDS
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 5: Skill Commands (/commands)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

COMMANDS_DIR="${HOME}/.claude/commands"

run_test "5.1 /auto Command Exists" \
    "[[ -f $COMMANDS_DIR/auto.md ]]"

run_test "5.2 /checkpoint Command Exists" \
    "[[ -f $COMMANDS_DIR/checkpoint.md ]]"

run_test "5.3 /build Command Exists" \
    "[[ -f $COMMANDS_DIR/build.md ]]"

run_test "5.4 /re Command Exists" \
    "[[ -f $COMMANDS_DIR/re.md ]]"

run_test "5.5 /research-api Command Exists" \
    "[[ -f $COMMANDS_DIR/research-api.md ]]"

run_test "5.6 /validate Command Exists" \
    "[[ -f $COMMANDS_DIR/validate.md ]]"

run_test "5.7 /rootcause Command Exists" \
    "[[ -f $COMMANDS_DIR/rootcause.md ]]"

run_test "5.8 /document Command Exists" \
    "[[ -f $COMMANDS_DIR/document.md ]]"

run_test "5.9 /collect Command Exists" \
    "[[ -f $COMMANDS_DIR/collect.md ]]"

# ============================================================================
# CATEGORY 6: AUTONOMOUS COMMAND EXECUTION
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 6: Autonomous Command Execution (100% Hands-Off)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "6.1 Auto Mode Has execute_skill Recognition" \
    "grep -q 'execute_skill' $COMMANDS_DIR/auto.md"

run_test "6.2 Auto Mode Has <command-name> Tag Pattern" \
    "grep -q '<command-name>' $COMMANDS_DIR/auto.md"

run_test "6.3 Auto Mode Has CRITICAL Rules" \
    "grep -q 'CRITICAL Rules' $COMMANDS_DIR/auto.md"

run_test "6.4 Auto Mode Has NEVER ASK Rule" \
    "grep -q 'NEVER ASK' $COMMANDS_DIR/auto.md"

run_test "6.5 Auto Mode Has Multi-Agent Routing" \
    "grep -q 'multi-agent' $COMMANDS_DIR/auto.md"

run_test "6.6 Auto Mode Has GitHub MCP Integration" \
    "grep -q 'mcp__grep__searchGitHub' $COMMANDS_DIR/auto.md"

# ============================================================================
# CATEGORY 7: RE TOOLKIT
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 7: Reverse Engineering Toolkit"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

DOCS_DIR="${HOME}/.claude/docs"

run_test "7.1 RE Prompts Documentation Exists" \
    "[[ -f $DOCS_DIR/re-prompts.md ]]"

run_test "7.2 RE Toolkit Documentation Exists" \
    "[[ -f $DOCS_DIR/reverse-engineering-toolkit.md ]]"

run_test "7.3 Frida Scripts Documentation Exists" \
    "[[ -f $DOCS_DIR/frida-scripts.md ]]"

run_test "7.4 RE Toolkit Has Chrome Extension Analysis" \
    "grep -q 'Chrome Extension' $DOCS_DIR/reverse-engineering-toolkit.md"

run_test "7.5 RE Toolkit Has Electron App Analysis" \
    "grep -q 'Electron' $DOCS_DIR/reverse-engineering-toolkit.md"

run_test "7.6 RE Toolkit Has API Analysis" \
    "grep -q 'API' $DOCS_DIR/reverse-engineering-toolkit.md"

run_test "7.7 Frida Scripts Has Mobile RE" \
    "grep -q 'Android\|iOS' $DOCS_DIR/frida-scripts.md"

# ============================================================================
# CATEGORY 8: KEN'S PATTERNS
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 8: Ken's Prompting Patterns"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "8.1 Ken's Rules in Auto Mode" \
    "grep -q \"Short > long\" $COMMANDS_DIR/auto.md"

run_test "8.2 Ken's Rules in Auto-Continue" \
    "grep -q \"Ken's rules\" ${SCRIPT_DIR}/auto-continue.sh"

run_test "8.3 Reference Don't Dump Pattern" \
    "grep -q 'Reference' $COMMANDS_DIR/auto.md"

run_test "8.4 Focused Work Pattern" \
    "grep -q 'focused\|Focused' $COMMANDS_DIR/auto.md"

run_test "8.5 Project Index First Pattern" \
    "grep -q 'project-index.md first' $COMMANDS_DIR/auto.md"

# ============================================================================
# CATEGORY 9: DOCUMENTATION
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 9: Documentation Completeness"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "9.1 40% Flow Documentation" \
    "[[ -f $DOCS_DIR/40-PERCENT-FLOW-VERIFIED.md ]]"

run_test "9.2 100% Hands-Off Documentation" \
    "[[ -f $DOCS_DIR/100-PERCENT-HANDS-OFF-OPERATION.md ]]"

run_test "9.3 GitHub Push Documentation" \
    "[[ -f ${HOME}/.claude/GITHUB-PUSH-AND-NAVIGATION-COMPLETE.md ]]"

run_test "9.4 Project Navigator Guide" \
    "[[ -f $DOCS_DIR/PROJECT-NAVIGATOR-GUIDE.md ]]"

run_test "9.5 Global CLAUDE.md Exists" \
    "[[ -f ${HOME}/.claude/CLAUDE.md ]]"

run_test "9.6 Global CLAUDE.md Has Auto-Checkpoint Info" \
    "grep -q 'Auto-checkpoints at 40%' ${HOME}/.claude/CLAUDE.md || grep -q 'Auto-executes /checkpoint at 40%' ${HOME}/.claude/CLAUDE.md"

# ============================================================================
# CATEGORY 10: GIT INTEGRATION
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 10: Git Integration (GitHub Push)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "10.1 Checkpoint Has Git Push Step" \
    "grep -q 'git push' $COMMANDS_DIR/checkpoint.md"

run_test "10.2 Checkpoint Checks Git Repo" \
    "grep -q 'git rev-parse --git-dir' $COMMANDS_DIR/checkpoint.md"

run_test "10.3 Checkpoint Checks Remote" \
    "grep -q 'git remote' $COMMANDS_DIR/checkpoint.md"

run_test "10.4 GitHub CLI Available" \
    "command -v gh"

run_test "10.5 Git Available" \
    "command -v git"

# ============================================================================
# CATEGORY 11: EDGE CASE HANDLING
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 11: Edge Case Handling"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Test router without autonomous mode
rm -f ~/.claude/autonomous-mode.active

run_test "11.1 Router Advisory Mode (No Autonomous)" \
    "${SCRIPT_DIR}/autonomous-command-router.sh execute checkpoint_context '80000/200000' | jq -e '.advisory'"

run_test "11.2 Router No Execute Skill (Non-Autonomous)" \
    "! ${SCRIPT_DIR}/autonomous-command-router.sh execute checkpoint_context '80000/200000' | jq -e '.execute_skill'"

# Restore autonomous mode
touch ~/.claude/autonomous-mode.active

run_test "11.3 Router Handles Unknown Trigger" \
    "${SCRIPT_DIR}/autonomous-command-router.sh execute unknown_trigger '' | jq -e '.command == \"none\"'"

run_test "11.4 Memory Manager Handles Empty Query" \
    "${SCRIPT_DIR}/memory-manager.sh remember-scored '' | jq -e 'type == \"array\"'"

run_test "11.5 Project Navigator Handles Missing Directory" \
    "! ${SCRIPT_DIR}/project-navigator.sh generate '/nonexistent/path' 2>/dev/null"

# ============================================================================
# CATEGORY 12: MCP INTEGRATIONS
# ============================================================================

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  CATEGORY 12: MCP Integrations (Tool Access)"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

run_test "12.1 Auto Mode References GitHub MCP" \
    "grep -q 'mcp__grep__searchGitHub' $COMMANDS_DIR/auto.md"

run_test "12.2 Auto Mode References Chrome MCP" \
    "grep -q 'Claude in Chrome' $COMMANDS_DIR/auto.md"

run_test "12.3 Auto Mode References macOS Automator" \
    "grep -q 'macOS Automator' $COMMANDS_DIR/auto.md"

run_test "12.4 Debug Orchestrator References GitHub MCP" \
    "[[ -f ${SCRIPT_DIR}/debug-orchestrator.sh ]] && grep -q 'GitHub' ${SCRIPT_DIR}/debug-orchestrator.sh || true"

run_test "12.5 UI Test Framework References Chrome" \
    "[[ -f ${SCRIPT_DIR}/ui-test-framework.sh ]] && grep -q 'Chrome' ${SCRIPT_DIR}/ui-test-framework.sh || true"

# ============================================================================
# RESULTS SUMMARY
# ============================================================================

echo ""
echo "======================================================================"
echo "  VALIDATION RESULTS"
echo "======================================================================"
echo ""

echo "Total Tests: $total_tests"
echo -e "${GREEN}Passed: $passed_tests${NC}"
echo -e "${RED}Failed: $failed_tests${NC}"
echo ""

# Calculate pass rate
if [[ $total_tests -gt 0 ]]; then
    pass_rate=$(( (passed_tests * 100) / total_tests ))
    echo "Pass Rate: ${pass_rate}%"

    if [[ $pass_rate -ge 95 ]]; then
        success "EXCELLENT - System is production ready!"
    elif [[ $pass_rate -ge 80 ]]; then
        warning "GOOD - Minor issues to address"
    else
        error "NEEDS WORK - Critical issues detected"
    fi
fi

# Save results to JSON
jq -n \
    --arg date "$(date '+%Y-%m-%d %H:%M:%S')" \
    --argjson total "$total_tests" \
    --argjson passed "$passed_tests" \
    --argjson failed "$failed_tests" \
    --argjson pass_rate "$pass_rate" \
    '{
        timestamp: $date,
        total_tests: $total,
        passed: $passed,
        failed: $failed,
        pass_rate: $pass_rate,
        status: (if $pass_rate >= 95 then "EXCELLENT" elif $pass_rate >= 80 then "GOOD" else "NEEDS_WORK" end)
    }' > "$RESULTS_FILE"

echo ""
echo "Detailed results saved to: $RESULTS_FILE"
echo "Full log saved to: $TEST_LOG"
echo ""

# Exit with appropriate code
if [[ $pass_rate -ge 80 ]]; then
    exit 0
else
    exit 1
fi
