# Phase 03: Error Handling & Recovery Improvements

This phase addresses error handling issues identified in the code review. The current system has unsafe `eval` usage, silent failures in known-fix application, and missing context budget enforcement. By the end of this phase, the autonomous system will have robust error recovery with proper sandboxing and graceful degradation.

## Tasks

- [x] Create error-handler.sh with safe execution patterns:
  - Create `/Users/imorgado/Desktop/claude-sovereign/hooks/error-handler.sh`
  - Implement error classification function with categories:
    - `transient`: Network timeouts, API rate limits (retry with backoff)
    - `permanent`: Invalid syntax, missing files (no retry, log and continue)
    - `critical`: Security violations, data corruption (halt and alert)
  - Implement exponential backoff for transient errors (1s, 2s, 4s, max 30s)
  - Replace unsafe `eval "$known_fix"` with subprocess execution:
    ```bash
    apply_known_fix() {
        local fix="$1"
        # Execute in subshell to isolate from parent
        (
            set +e
            bash -c "$fix" 2>&1
            exit $?
        )
        return $?
    }
    ```
  - Add fix verification: only return success if fix actually resolves the error
  - Log all fix attempts with timestamps and outcomes

- [x] Implement context budget enforcement in agent-loop:
  - If agent-loop.sh doesn't exist, create it at `/Users/imorgado/Desktop/claude-sovereign/hooks/agent-loop.sh`
  - Add context tracking at start of each iteration:
    ```bash
    ITERATION_CONTEXT=0
    MAX_ITERATION_CONTEXT=10000  # tokens per iteration
    ```
  - Before executing actions, check context budget:
    ```bash
    if [[ $ITERATION_CONTEXT -gt $MAX_ITERATION_CONTEXT ]]; then
        log "Context budget exceeded, triggering compact"
        "$MEMORY_MANAGER" context-compact
        ITERATION_CONTEXT=0
    fi
    ```
  - Track context accumulation by estimating token count (chars / 4)
  - Integrate with auto-continue.sh checkpoint triggering

- [x] Add graceful degradation for missing dependencies:
  - Update coordinator.sh to handle missing hooks gracefully
  - For each optional hook call, wrap with existence check:
    ```bash
    if [[ -x "$HOOK_PATH" ]]; then
        result=$("$HOOK_PATH" "$@" 2>/dev/null) || {
            log_failure "$HOOK_NAME" "execution failed"
            show_advisory "Hook $HOOK_NAME failed - continuing with reduced functionality"
            result="{}"
        }
    else
        log "Optional hook $HOOK_NAME not available - skipping"
        result="{}"
    fi
    ```
  - Ensure all hook failures are logged but don't halt execution
  - Add summary of degraded features at end of coordination

- [x] Implement checkpoint pruning to prevent disk exhaustion:
  - Update memory-manager.sh `prune_checkpoints()` function
  - Add automatic pruning trigger: when checkpoint count > 20, prune to 10
  - Call pruning after each new checkpoint creation
  - Add `prune_old_checkpoints()` to init_memory():
    ```bash
    local ckpt_count=$(ls -1 "$MEMORY_DIR/checkpoints/"*.json 2>/dev/null | wc -l)
    if [[ $ckpt_count -gt 20 ]]; then
        prune_checkpoints 10
    fi
    ```
  - Log pruning operations with count of deleted checkpoints

- [x] Add health monitoring to self-healing system:
  - Create `/Users/imorgado/Desktop/claude-sovereign/hooks/self-healing.sh` if it doesn't exist
  - Implement `health_check()` function that verifies:
    - Memory files are valid JSON
    - Checkpoint directory isn't corrupted
    - Action log isn't oversized (> 10MB)
    - No orphaned lock files older than 1 hour
  - Implement `recover()` function that:
    - Removes stale lock files
    - Truncates oversized logs
    - Repairs invalid JSON by restoring from checkpoint
  - Add health status output: "healthy", "degraded", "unhealthy"

- [x] Create recovery integration test:
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/test-recovery.sh`
  - Test 1: Corrupt memory JSON → health check detects → recover repairs
  - Test 2: Orphaned lock file → recovery removes after timeout
  - Test 3: Oversized action log → recovery truncates
  - Test 4: Missing checkpoint → graceful degradation (no crash)
  - Test 5: Error handler classifies errors correctly
  - Verify all recovery paths execute without crashes

## Completion Notes (2026-01-17)

All 6 tasks completed successfully. Test results: 5/5 tests passed (100% success rate).

### Files Created:
- `hooks/error-handler.sh` (330 lines) - Safe subprocess execution, error classification, backoff logic
- `hooks/agent-loop.sh` (530 lines) - Context budget enforcement with token tracking
- `hooks/self-healing.sh` (380 lines) - Health monitoring and recovery functions
- `tests/test-recovery.sh` (290 lines) - Integration tests for all recovery paths

### Files Modified:
- `hooks/coordinator.sh` - Added graceful degradation helpers and degradation summary
- `hooks/memory-manager.sh` - Added auto_prune_old_checkpoints function, integrated with init and checkpoint

### Key Features Implemented:
1. **Safe execution patterns** - No more unsafe `eval`, all fixes run in isolated subshells
2. **Context budget enforcement** - Tracks tokens per iteration and total session
3. **Graceful degradation** - Missing hooks logged but don't halt execution
4. **Automatic checkpoint pruning** - Prevents disk exhaustion (prunes at >20 checkpoints)
5. **Health monitoring** - Validates JSON, detects oversized logs, finds orphaned locks
6. **Self-healing recovery** - Repairs corrupt files, removes stale locks, truncates logs
