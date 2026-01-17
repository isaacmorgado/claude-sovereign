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

- [ ] Enhance RRF implementation for true 4-signal ranking:
  - Locate `reciprocal_rank_fusion_enhanced()` function (around line 776-810)
  - Verify all 4 signals are properly weighted:
    - BM25 score (exact term matching)
    - Relevance score (semantic word overlap)
    - Recency score (temporal decay)
    - Importance score (user-defined priority)
  - Fix the jq query to handle edge cases:
    - Empty arrays should return empty result, not error
    - Null scores should default to 0, not cause ranking errors
    - Ensure stable sort (deterministic ordering for equal scores)
  - Add debug logging option to trace ranking decisions

- [ ] Optimize retrieve_hybrid() performance:
  - Locate `retrieve_hybrid()` function (around line 820-943)
  - Current issue: reads entire episodic/semantic memory for every query
  - Add early termination when top results are clearly best:
    ```bash
    # If top result has score > 0.9, skip remaining evaluation
    local top_score=$(echo "$results" | jq '.[0].retrievalScore // 0')
    if (( $(echo "$top_score > 0.9" | bc -l) )); then
        break
    fi
    ```
  - Add caching for BM25 scores within session
  - Limit pattern scanning to top 50 most recent patterns

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
