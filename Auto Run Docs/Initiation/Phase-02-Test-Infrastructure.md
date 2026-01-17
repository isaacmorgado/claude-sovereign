# Phase 02: Test Infrastructure & Validation

This phase establishes a comprehensive test suite for the autonomous system. The existing comprehensive-validation.sh provides a foundation, but we need targeted unit tests for each hook and integration tests for the complete flow. By the end of this phase, there will be automated tests that verify the entire autonomous operation pipeline works correctly.

## Tasks

- [x] Create unit test framework for bash hooks:
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/test-framework.sh`
  - Implement `assert_equals()`, `assert_contains()`, `assert_file_exists()`, `assert_exit_code()` functions
  - Implement `run_test()` wrapper that captures stdout, stderr, and exit code
  - Implement `test_suite_start()` and `test_suite_end()` for summary reporting
  - Track pass/fail counts and output final summary
  - Make executable with `chmod +x`

- [x] Create memory-manager unit tests:
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/test-memory-manager.sh`
  - Source the test-framework.sh
  - Test working memory operations:
    - `set_task()` creates valid JSON
    - `add_context()` appends and sorts by importance
    - `get_working()` returns valid JSON
    - `clear_working()` resets state
  - Test episodic memory operations:
    - `record_episode()` returns episode ID
    - `search_episodes()` finds matching episodes
    - `get_recent_episodes()` respects limit parameter
  - Test semantic memory operations:
    - `add_fact()` creates/updates facts correctly
    - `add_pattern()` stores patterns with success rate
    - `find_patterns()` retrieves matching patterns
  - Test checkpoint/restore:
    - `checkpoint()` creates checkpoint file
    - `restore_checkpoint()` restores memory state
    - `list_checkpoints()` returns valid JSON array

- [x] Create auto-continue integration tests:
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/test-auto-continue.sh`
  - Test 1: Below threshold (39%) should exit 0 without blocking
  - Test 2: At threshold (40%) should output JSON with "decision": "block"
  - Test 3: Above threshold (60%) should trigger checkpoint signal
  - Test 4: Stop words ("stop", "pause") should allow normal exit
  - Test 5: Disabled file (.claude/auto-continue-disabled) should skip
  - Mock the HOOK_INPUT JSON for each test scenario

- [x] Create swarm-orchestrator integration tests:
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/test-swarm-orchestrator.sh`
  - Test 1: `spawn 3 "test task"` creates correct directory structure
  - Test 2: Task decomposition produces valid JSON with subtasks
  - Test 3: Agent task files contain expected content
  - Test 4: `collect` aggregates results from agent directories
  - Test 5: Git integration skips gracefully when not in repo
  - Test 6: MCP detection works with and without config file

- [x] Create coordinator end-to-end test:
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/test-coordinator-e2e.sh`
  - Test full coordination flow with a mock task
  - Verify each phase executes:
    - Phase 1: Pre-execution (reasoning mode, strategy, risk assessment)
    - Phase 2: Execution (plan creation, agent routing)
    - Phase 3: Post-execution (learning, reflection)
  - Check that result JSON contains all expected fields
  - Verify graceful degradation when optional hooks are missing

- [x] Create test runner that executes all test suites:
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/run-all-tests.sh`
  - Run each test file in sequence
  - Collect results from all suites
  - Output consolidated pass/fail summary
  - Exit with non-zero code if any test fails
  - Make executable with `chmod +x`

- [x] Run all tests and document results:
  - Execute `./tests/run-all-tests.sh`
  - Create `/Users/imorgado/Desktop/claude-sovereign/tests/RESULTS.md` with:
    - Front matter: `type: report`, `title: Test Results`, `created: [today]`, `tags: [testing, validation]`
    - Summary of pass/fail counts
    - List of any failing tests with error messages
    - Recommendations for fixes if any tests fail
