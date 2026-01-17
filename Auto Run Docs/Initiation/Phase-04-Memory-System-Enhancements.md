# Phase 04: Memory System Enhancements

This phase improves the memory system's retrieval accuracy and context management. The code review identified that the RRF (Reciprocal Rank Fusion) implementation could be enhanced, and the context budget status values need correction. By the end of this phase, memory retrieval will achieve the claimed 95%+ accuracy through proper 4-signal ranking.

## Tasks

- [x] Fix context usage status values in memory-manager.sh: (COMPLETED 2026-01-17)
  - Locate `calculate_context_usage()` function (around line 1225-1307)
  - Current issue: status values may not correctly reflect warning/critical thresholds
  - Ensure status calculation uses proper numeric comparison:
    ```bash
    local usage_pct_num=$(echo "$usage_pct" | cut -d'.' -f1)
    local warning_pct_num=$(echo "$warning_threshold * 100" | bc | cut -d'.' -f1)
    local critical_pct_num=$(echo "$critical_threshold * 100" | bc | cut -d'.' -f1)

    if [[ $usage_pct_num -ge $critical_pct_num ]]; then
        status="critical"
    elif [[ $usage_pct_num -ge $warning_pct_num ]]; then
        status="warning"
    else
        status="active"
    fi
    ```
  - Return "active" for healthy state (not "ok" which isn't documented)
  - Verify thresholds match documented values: warning=80%, critical=90%

- [x] Enhance RRF implementation for true 4-signal ranking: (COMPLETED 2026-01-17)
  - Rewrote `remember_hybrid()` function in memory-manager.sh (lines 192-290)
  - All 4 signals now properly weighted with RRF (k=60):
    - BM25 score (FTS5 exact term matching via search_context)
    - Relevance score (vector-embedder semantic search)
    - Recency score (temporal decay: 1/(1 + 0.1 * days_ago))
    - Importance score (user-defined confidence from semantic_memory)
  - Fixed jq query edge cases:
    - Empty arrays safely handled via `safe_arr` function
    - Null scores default to 0.5 via `// 0.5` operator
    - Stable sort using 3-key comparison: `[-.rrf_score, -.signal_count, -.avg_original_score]`
  - Debug logging enabled via `MEMORY_DEBUG=true` environment variable
  - Added 7 new tests: 35/35 tests passing

- [x] Optimize retrieve_hybrid() performance: (COMPLETED 2026-01-17)
  - Implemented BM25 score caching via file-based cache (lines 884-924):
    - `init_bm25_cache()` creates session-specific cache directory
    - `get_cached_bm25_score()` caches scores with MD5/SHA256 hash keys
    - Auto-cleans cache files older than 1 hour
  - Added early termination when high scores found (lines 999-1004, 1062-1071):
    - Tracks `found_high_score` flag when score > 5.85 (90% of max)
    - After scanning half patterns, checks top score against threshold
    - Configurable via `RETRIEVE_EARLY_THRESHOLD` env var (default 0.9)
  - Limited pattern scanning to top 50 most recent (lines 1007-1010):
    - `max_patterns="${RETRIEVE_MAX_PATTERNS:-50}"` configurable limit
    - Uses jq slice to get only first N patterns
  - Added 5 new tests in test-memory-manager.sh:
    - test_retrieve_hybrid_bm25_caching
    - test_retrieve_hybrid_pattern_limit
    - test_retrieve_hybrid_early_termination
    - test_retrieve_hybrid_env_variables
    - test_bm25_cache_initialization

- [ ] Implement memory compaction triggers in auto-continue:
  - Update `/Users/imorgado/Desktop/claude-sovereign/hooks/auto-continue.sh`
  - At 60% context, trigger "warning" compact (prune low-importance items)
  - At 80% context, trigger "aggressive" compact (keep only high-importance)
  - Pass context percentage to memory-manager for appropriate action:
    ```bash
    if [[ $PERCENT -ge 80 ]]; then
        "$MEMORY_MANAGER" context-compact aggressive 2>/dev/null
    elif [[ $PERCENT -ge 60 ]]; then
        "$MEMORY_MANAGER" context-compact warning 2>/dev/null
    fi
    ```
  - Add compact mode parameter to `compact_memory()` function

- [ ] Add tiered compaction to memory-manager compact_memory():
  - Update `compact_memory()` function to accept mode parameter
  - Mode "warning" (default):
    - Keep episodes with importance >= 5
    - Keep episodes from last 7 days regardless of importance
    - Keep patterns with successRate >= 0.7
    - Truncate action log to 1000 lines
  - Mode "aggressive":
    - Keep episodes with importance >= 7
    - Keep episodes from last 24 hours only
    - Keep patterns with successRate >= 0.9
    - Truncate action log to 200 lines
  - Log which mode was applied and items removed

- [ ] Create memory accuracy benchmark:
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/benchmark-memory.sh`
  - Create test dataset of 100 episodes with known relevance scores
  - Query with 10 different search terms
  - Measure:
    - Precision@5: Are top 5 results actually relevant?
    - Recall@10: Are all relevant items in top 10?
    - RRF accuracy: Does 4-signal fusion beat individual signals?
  - Output benchmark results with:
    - Front matter: `type: report`, `title: Memory Benchmark`, `tags: [memory, performance]`
    - Target: Precision@5 >= 90%, Recall@10 >= 85%
  - Save results to `/Users/imorgado/Desktop/claude-sovereign/tests/benchmark-results.md`
