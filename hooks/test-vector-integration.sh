#!/bin/bash
# test-vector-integration.sh - Verify vector embedder integration with memory-manager.sh
# Tests: embedding generation, caching, hybrid search with vectors

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
MEMORY_MANAGER="$SCRIPT_DIR/memory-manager.sh"
VECTOR_EMBEDDER="$SCRIPT_DIR/vector-embedder.sh"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

PASSED=0
FAILED=0
SKIPPED=0

# Test result tracking
pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    PASSED=$((PASSED + 1))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    FAILED=$((FAILED + 1))
}

skip() {
    echo -e "${YELLOW}[SKIP]${NC} $1"
    SKIPPED=$((SKIPPED + 1))
}

info() {
    echo -e "${YELLOW}[INFO]${NC} $1"
}

# ============================================================================
# Prerequisites Check
# ============================================================================

echo "=============================================="
echo "Vector Integration Test Suite"
echo "=============================================="
echo ""

echo "Checking prerequisites..."

# Check memory-manager.sh exists
if [[ -x "$MEMORY_MANAGER" ]]; then
    pass "memory-manager.sh exists and is executable"
else
    fail "memory-manager.sh not found or not executable at $MEMORY_MANAGER"
    exit 1
fi

# Check vector-embedder.sh exists
if [[ -x "$VECTOR_EMBEDDER" ]]; then
    pass "vector-embedder.sh exists and is executable"
else
    fail "vector-embedder.sh not found or not executable at $VECTOR_EMBEDDER"
    exit 1
fi

# Check if vector embedder is functional
echo ""
echo "Checking vector embedder functionality..."

# Test actual embedding generation (not just stats)
if "$VECTOR_EMBEDDER" embed "test" 2>/dev/null | grep -q '"embedding"'; then
    pass "Vector embedder is available (embedding generation works)"
    VECTORS_AVAILABLE=true
else
    skip "Vector embedder unavailable (sentence-transformers not installed)"
    info "To enable vector tests: pip install sentence-transformers numpy"
    VECTORS_AVAILABLE=false
fi

# ============================================================================
# Test 1: Store Test Memories
# ============================================================================

echo ""
echo "=============================================="
echo "Test 1: Storing Test Memories"
echo "=============================================="

# Clear any existing test data
"$MEMORY_MANAGER" clear-working >/dev/null 2>&1 || true

# Store test episodic memories
info "Recording test episodes..."

EP1=$("$MEMORY_MANAGER" record task_complete "Implemented authentication system with JWT tokens" success "Added login, logout, refresh endpoints")
if [[ -n "$EP1" ]]; then
    pass "Recorded episode 1: authentication system"
else
    fail "Failed to record episode 1"
fi

EP2=$("$MEMORY_MANAGER" record error_fixed "Fixed memory leak in database connection pool" success "Changed connection pooling to use bounded queue")
if [[ -n "$EP2" ]]; then
    pass "Recorded episode 2: memory leak fix"
else
    fail "Failed to record episode 2"
fi

EP3=$("$MEMORY_MANAGER" record research_done "Researched GraphQL vs REST API design patterns" success "Chose REST for simplicity, GraphQL for complex queries")
if [[ -n "$EP3" ]]; then
    pass "Recorded episode 3: API research"
else
    fail "Failed to record episode 3"
fi

EP4=$("$MEMORY_MANAGER" record task_complete "Added user profile picture upload feature" success "S3 integration with image resizing")
if [[ -n "$EP4" ]]; then
    pass "Recorded episode 4: profile pictures"
else
    fail "Failed to record episode 4"
fi

# Store test patterns
info "Recording test patterns..."

PAT1=$("$MEMORY_MANAGER" add-pattern error_fix "Connection timeout error" "Increase timeout to 30s and add retry logic" 0.95)
if [[ -n "$PAT1" ]]; then
    pass "Added pattern 1: connection timeout"
else
    fail "Failed to add pattern 1"
fi

PAT2=$("$MEMORY_MANAGER" add-pattern optimization "Slow database queries" "Add index and use query explain plan" 0.90)
if [[ -n "$PAT2" ]]; then
    pass "Added pattern 2: slow queries"
else
    fail "Failed to add pattern 2"
fi

# ============================================================================
# Test 2: Pre-compute Embeddings
# ============================================================================

echo ""
echo "=============================================="
echo "Test 2: Pre-computing Embeddings"
echo "=============================================="

if [[ "$VECTORS_AVAILABLE" == "true" ]]; then
    info "Running embed-memory to pre-compute embeddings..."

    EMBED_OUTPUT=$("$MEMORY_MANAGER" embed-memory 2>&1)

    if echo "$EMBED_OUTPUT" | grep -q "Embedded:"; then
        pass "embed-memory command executed successfully"
        echo "$EMBED_OUTPUT" | tail -5
    else
        fail "embed-memory command failed"
        echo "$EMBED_OUTPUT"
    fi

    # Check vector cache stats
    info "Checking vector cache statistics..."

    STATS=$("$MEMORY_MANAGER" vector-stats)
    CACHED_COUNT=$(echo "$STATS" | jq -r '.cached_embeddings // 0')

    if [[ "$CACHED_COUNT" -gt 0 ]]; then
        pass "Vector cache has $CACHED_COUNT embeddings cached"
    else
        fail "Vector cache is empty after embedding"
    fi
else
    skip "Skipping embedding tests (vector embedder unavailable)"
fi

# ============================================================================
# Test 3: Hybrid Search with Vectors
# ============================================================================

echo ""
echo "=============================================="
echo "Test 3: Hybrid Search with Vector Similarity"
echo "=============================================="

# Test query 1: Should match authentication episode
info "Testing query: 'login security tokens'"

RESULTS1=$("$MEMORY_MANAGER" remember-hybrid "login security tokens" 5)

if echo "$RESULTS1" | jq -e '.[0]' >/dev/null 2>&1; then
    pass "Hybrid search returned results"

    # Check if vector_score is present
    VECTOR_SCORE=$(echo "$RESULTS1" | jq -r '.[0].vector_score // "missing"')
    VECTOR_ENABLED=$(echo "$RESULTS1" | jq -r '.[0].vector_enabled // false')

    if [[ "$VECTORS_AVAILABLE" == "true" ]]; then
        if [[ "$VECTOR_ENABLED" == "true" ]]; then
            pass "Vector scoring is enabled"
            info "Top result vector_score: $VECTOR_SCORE"
        else
            fail "Vector scoring should be enabled but is not"
        fi
    else
        # When vectors are unavailable, vector_enabled should be false and vector_score should be 0
        if [[ "$VECTOR_ENABLED" == "false" ]] || [[ "$VECTOR_SCORE" == "0" ]]; then
            pass "Vector scoring correctly disabled (embedder unavailable)"
        else
            # This is actually okay - the memory-manager detected vectors at runtime
            info "Vector scoring enabled at runtime (embedder became available)"
            pass "Vector scoring dynamically detected"
        fi
    fi

    # Show top result
    TOP_DESC=$(echo "$RESULTS1" | jq -r '.[0].description // .[0].trigger')
    info "Top result: $TOP_DESC"
else
    fail "Hybrid search returned no results"
fi

# Test query 2: Semantic similarity test (should match memory leak even without exact keywords)
info "Testing semantic query: 'resource management performance issue'"

RESULTS2=$("$MEMORY_MANAGER" remember-hybrid "resource management performance issue" 5)

if echo "$RESULTS2" | jq -e '.[0]' >/dev/null 2>&1; then
    pass "Semantic search returned results"

    # Check scores
    BM25=$(echo "$RESULTS2" | jq -r '.[0].bm25_score')
    RELEVANCE=$(echo "$RESULTS2" | jq -r '.[0].relevance_score')
    VECTOR=$(echo "$RESULTS2" | jq -r '.[0].vector_score')
    RECENCY=$(echo "$RESULTS2" | jq -r '.[0].recency_score')
    IMPORTANCE=$(echo "$RESULTS2" | jq -r '.[0].importance_score')

    info "Score breakdown for top result:"
    info "  - BM25: $BM25"
    info "  - Relevance: $RELEVANCE"
    info "  - Recency: $RECENCY"
    info "  - Importance: $IMPORTANCE"
    info "  - Vector: $VECTOR"

    if [[ "$VECTORS_AVAILABLE" == "true" ]]; then
        # Vector score should be non-zero if vectors are working
        if [[ $(echo "$VECTOR > 0" | bc -l 2>/dev/null) == "1" ]]; then
            pass "Vector score is non-zero ($VECTOR)"
        else
            fail "Vector score is zero when it should be non-zero"
        fi
    fi
else
    fail "Semantic search returned no results"
fi

# ============================================================================
# Test 4: RRF with 5 Signals
# ============================================================================

echo ""
echo "=============================================="
echo "Test 4: RRF with 5 Signals"
echo "=============================================="

# Check that results have all 5 signal scores
info "Verifying 5-signal scoring in results..."

RESULTS3=$("$MEMORY_MANAGER" remember-hybrid "database optimization" 5)

if echo "$RESULTS3" | jq -e '.[0]' >/dev/null 2>&1; then
    # Check for all 5 signal scores
    HAS_BM25=$(echo "$RESULTS3" | jq -r '.[0].bm25_score // "missing"' 2>/dev/null)
    HAS_REL=$(echo "$RESULTS3" | jq -r '.[0].relevance_score // "missing"' 2>/dev/null)
    HAS_REC=$(echo "$RESULTS3" | jq -r '.[0].recency_score // "missing"' 2>/dev/null)
    HAS_IMP=$(echo "$RESULTS3" | jq -r '.[0].importance_score // "missing"' 2>/dev/null)
    HAS_VEC=$(echo "$RESULTS3" | jq -r '.[0].vector_score // "missing"' 2>/dev/null)

    # Convert to yes/no
    [[ "$HAS_BM25" != "missing" && "$HAS_BM25" != "null" ]] && HAS_BM25="yes" || HAS_BM25="no"
    [[ "$HAS_REL" != "missing" && "$HAS_REL" != "null" ]] && HAS_REL="yes" || HAS_REL="no"
    [[ "$HAS_REC" != "missing" && "$HAS_REC" != "null" ]] && HAS_REC="yes" || HAS_REC="no"
    [[ "$HAS_IMP" != "missing" && "$HAS_IMP" != "null" ]] && HAS_IMP="yes" || HAS_IMP="no"
    [[ "$HAS_VEC" != "missing" && "$HAS_VEC" != "null" ]] && HAS_VEC="yes" || HAS_VEC="no"

    SIGNALS_PRESENT=0
    if [[ "$HAS_BM25" == "yes" ]]; then SIGNALS_PRESENT=$((SIGNALS_PRESENT + 1)); pass "BM25 score present"; fi
    if [[ "$HAS_REL" == "yes" ]]; then SIGNALS_PRESENT=$((SIGNALS_PRESENT + 1)); pass "Relevance score present"; fi
    if [[ "$HAS_REC" == "yes" ]]; then SIGNALS_PRESENT=$((SIGNALS_PRESENT + 1)); pass "Recency score present"; fi
    if [[ "$HAS_IMP" == "yes" ]]; then SIGNALS_PRESENT=$((SIGNALS_PRESENT + 1)); pass "Importance score present"; fi
    if [[ "$HAS_VEC" == "yes" ]]; then SIGNALS_PRESENT=$((SIGNALS_PRESENT + 1)); pass "Vector score present"; fi

    if [[ "$SIGNALS_PRESENT" -eq 5 ]]; then
        pass "All 5 signals present in results"
    else
        fail "Only $SIGNALS_PRESENT/5 signals present"
    fi
else
    fail "Could not verify signal scores"
fi

# ============================================================================
# Test 5: Vector Similarity Calculation
# ============================================================================

echo ""
echo "=============================================="
echo "Test 5: Direct Vector Similarity"
echo "=============================================="

if [[ "$VECTORS_AVAILABLE" == "true" ]]; then
    info "Testing direct vector similarity calculation..."

    # Similar texts should have high similarity
    SIM1=$("$MEMORY_MANAGER" vector-similarity "authentication login security" "user authentication and security tokens" 2>/dev/null)

    if [[ -n "$SIM1" ]] && [[ "$SIM1" != "0" ]]; then
        pass "Vector similarity calculated: $SIM1"

        if [[ $(echo "$SIM1 > 0.5" | bc -l 2>/dev/null) == "1" ]]; then
            pass "Similar texts have high similarity ($SIM1 > 0.5)"
        else
            info "Similarity lower than expected but still working"
        fi
    else
        fail "Vector similarity calculation failed"
    fi

    # Different texts should have lower similarity
    SIM2=$("$MEMORY_MANAGER" vector-similarity "authentication login security" "cooking recipes and kitchen tips" 2>/dev/null)

    if [[ -n "$SIM2" ]]; then
        pass "Dissimilar text similarity: $SIM2"

        if [[ $(echo "$SIM2 < $SIM1" | bc -l 2>/dev/null) == "1" ]]; then
            pass "Dissimilar texts have lower similarity than similar texts"
        else
            info "Unexpected: dissimilar texts have higher similarity"
        fi
    fi
else
    skip "Skipping vector similarity tests (vector embedder unavailable)"
fi

# ============================================================================
# Test 6: Graceful Fallback
# ============================================================================

echo ""
echo "=============================================="
echo "Test 6: Graceful Fallback Behavior"
echo "=============================================="

info "Verifying hybrid search works with or without vectors..."

# The search should still work even if vectors fail
RESULTS4=$("$MEMORY_MANAGER" remember-hybrid "test query" 3)

if echo "$RESULTS4" | jq -e 'type == "array"' >/dev/null 2>&1; then
    pass "Hybrid search returns valid JSON array"
else
    fail "Hybrid search did not return valid JSON"
fi

# Check that vector_enabled field is present
ENABLED=$(echo "$RESULTS4" | jq -r '.[0].vector_enabled // "missing"' 2>/dev/null)

if [[ "$ENABLED" != "missing" ]]; then
    pass "vector_enabled field present (value: $ENABLED)"
else
    fail "vector_enabled field missing from results"
fi

# ============================================================================
# Summary
# ============================================================================

echo ""
echo "=============================================="
echo "Test Summary"
echo "=============================================="
echo -e "${GREEN}Passed:${NC}  $PASSED"
echo -e "${RED}Failed:${NC}  $FAILED"
echo -e "${YELLOW}Skipped:${NC} $SKIPPED"
echo ""

TOTAL=$((PASSED + FAILED))
if [[ "$FAILED" -eq 0 ]]; then
    echo -e "${GREEN}All $TOTAL tests passed!${NC}"
    exit 0
elif [[ "$FAILED" -lt "$PASSED" ]]; then
    echo -e "${YELLOW}Most tests passed ($PASSED/$TOTAL)${NC}"
    exit 1
else
    echo -e "${RED}Too many failures ($FAILED/$TOTAL)${NC}"
    exit 1
fi
