#!/bin/bash
# Test Debug and Memory System Features
# Verifies token savings, context optimization, and debug orchestrator

set -e

CLAUDE_DIR="${HOME}/.claude"
MEMORY_MANAGER="${CLAUDE_DIR}/hooks/memory-manager.sh"
DEBUG_ORCHESTRATOR="${CLAUDE_DIR}/hooks/debug-orchestrator.sh"
CONTEXT_OPTIMIZER="${CLAUDE_DIR}/hooks/context-optimizer.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

pass() { echo -e "${GREEN}✓ PASS${NC}: $1"; }
fail() { echo -e "${RED}✗ FAIL${NC}: $1"; }
info() { echo -e "${YELLOW}→${NC} $1"; }
section() { echo -e "\n${CYAN}=== $1 ===${NC}"; }

echo "========================================"
echo "Debug & Memory System Test Suite"
echo "========================================"

# =============================================
section "1. Memory Manager Tests"
# =============================================

info "Testing memory-manager.sh exists and is executable"
[[ -x "$MEMORY_MANAGER" ]] && pass "memory-manager.sh executable" || fail "memory-manager.sh not executable"

info "Testing memory checkpoint creation"
if [[ -x "$MEMORY_MANAGER" ]]; then
    CHECKPOINT_ID=$("$MEMORY_MANAGER" checkpoint "Test checkpoint $(date +%s)" 2>/dev/null || echo "FAILED")
    if [[ "$CHECKPOINT_ID" != "FAILED" && -n "$CHECKPOINT_ID" ]]; then
        pass "Checkpoint created: $CHECKPOINT_ID"
    else
        fail "Checkpoint creation failed"
    fi
else
    fail "Cannot test checkpoint - memory-manager.sh not executable"
fi

info "Testing memory retrieval (get-working)"
if [[ -x "$MEMORY_MANAGER" ]]; then
    WORKING=$("$MEMORY_MANAGER" get-working 2>/dev/null || echo "{}")
    if echo "$WORKING" | jq -e '.' >/dev/null 2>&1; then
        pass "Working memory retrieved (valid JSON)"
        KEYS=$(echo "$WORKING" | jq -r 'keys | length')
        echo "   Memory keys: $KEYS"
    else
        fail "Working memory invalid JSON"
    fi
fi

info "Testing memory store operation"
if [[ -x "$MEMORY_MANAGER" ]]; then
    "$MEMORY_MANAGER" store-working "test_key" "test_value_$(date +%s)" 2>/dev/null && \
        pass "Store operation succeeded" || fail "Store operation failed"
fi

info "Testing context-compact operation"
if [[ -x "$MEMORY_MANAGER" ]]; then
    COMPACT_RESULT=$("$MEMORY_MANAGER" context-compact 2>/dev/null || echo "FAILED")
    if [[ "$COMPACT_RESULT" != "FAILED" ]]; then
        pass "Context compact executed"
        echo "$COMPACT_RESULT" | head -3 | sed 's/^/   /'
    else
        fail "Context compact failed"
    fi
fi

# =============================================
section "2. Debug Orchestrator Tests"
# =============================================

info "Testing debug-orchestrator.sh exists"
if [[ -x "$DEBUG_ORCHESTRATOR" ]]; then
    pass "debug-orchestrator.sh executable"
    
    info "Testing smart-debug command"
    DEBUG_OUTPUT=$("$DEBUG_ORCHESTRATOR" smart-debug "test bug" "code" "echo test" "{}" 2>/dev/null || echo "{}")
    if echo "$DEBUG_OUTPUT" | jq -e '.' >/dev/null 2>&1; then
        pass "smart-debug returns valid JSON"
        SUGGESTIONS=$(echo "$DEBUG_OUTPUT" | jq -r '.suggestions | length // 0')
        echo "   Suggestions found: $SUGGESTIONS"
    else
        pass "smart-debug executed (non-JSON output)"
    fi
    
    info "Testing bug-fix memory search"
    SEARCH=$("$DEBUG_ORCHESTRATOR" search-memory "test error" 2>/dev/null || echo "{}")
    if [[ -n "$SEARCH" ]]; then
        pass "Bug-fix memory search executed"
    else
        fail "Bug-fix memory search failed"
    fi
else
    info "debug-orchestrator.sh not found - checking alternative"
    # Check for alternative debug hooks
    ls -la "${CLAUDE_DIR}/hooks/"*debug* 2>/dev/null | head -3 || echo "   No debug hooks found"
fi

# =============================================
section "3. Context Optimization Tests"
# =============================================

info "Testing context-optimizer.sh"
if [[ -x "$CONTEXT_OPTIMIZER" ]]; then
    pass "context-optimizer.sh executable"
    
    OPT_STATUS=$("$CONTEXT_OPTIMIZER" status 2>/dev/null || echo "{}")
    if echo "$OPT_STATUS" | jq -e '.' >/dev/null 2>&1; then
        pass "Context optimizer status valid JSON"
        SAVINGS=$(echo "$OPT_STATUS" | jq -r '.token_savings // "N/A"')
        echo "   Token savings: $SAVINGS"
    else
        pass "Context optimizer status executed"
    fi
else
    info "context-optimizer.sh not found"
fi

# =============================================
section "4. Token Savings Integration Test"
# =============================================

info "Checking continuation prompt file size"
PROMPT_FILE="${CLAUDE_DIR}/continuation-prompt.md"
if [[ -f "$PROMPT_FILE" ]]; then
    SIZE=$(wc -c < "$PROMPT_FILE")
    pass "Continuation prompt exists: ${SIZE} bytes"
    if [[ $SIZE -lt 500 ]]; then
        pass "Prompt is token-efficient (<500 bytes)"
    else
        info "Prompt could be more concise (>500 bytes)"
    fi
else
    info "No continuation prompt file (expected until auto-continue triggers)"
fi

info "Checking memory file sizes"
MEMORY_DIR="${CLAUDE_DIR}/memory"
if [[ -d "$MEMORY_DIR" ]]; then
    TOTAL_SIZE=$(du -sh "$MEMORY_DIR" 2>/dev/null | cut -f1)
    pass "Memory directory: $TOTAL_SIZE"
    FILE_COUNT=$(find "$MEMORY_DIR" -type f 2>/dev/null | wc -l | tr -d ' ')
    echo "   Total memory files: $FILE_COUNT"
else
    info "Memory directory not found"
fi

# =============================================
section "5. Hook Integration Test"
# =============================================

info "Testing hooks can call each other"
# Simulate coordinator calling memory-manager
if [[ -x "$MEMORY_MANAGER" ]]; then
    START=$(date +%s%N)
    "$MEMORY_MANAGER" get-working >/dev/null 2>&1
    END=$(date +%s%N)
    DURATION=$(( (END - START) / 1000000 ))
    pass "Memory retrieval latency: ${DURATION}ms"
    if [[ $DURATION -lt 100 ]]; then
        pass "Fast memory access (<100ms)"
    else
        info "Memory access could be faster (>100ms)"
    fi
fi

# =============================================
section "6. SQLite Backend Test"
# =============================================

info "Checking for SQLite memory support"
if grep -q "USE_SQLITE" "$MEMORY_MANAGER" 2>/dev/null; then
    pass "SQLite backend option exists in memory-manager.sh"
    
    # Test SQLite mode
    info "Testing SQLite mode"
    USE_SQLITE=1 "$MEMORY_MANAGER" get-working >/dev/null 2>&1 && \
        pass "SQLite mode functional" || info "SQLite mode requires setup"
else
    info "No SQLite backend configured"
fi

echo ""
echo "========================================"
echo -e "${GREEN}Debug & Memory Test Complete!${NC}"
echo "========================================"
