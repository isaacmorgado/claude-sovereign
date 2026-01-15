#!/bin/bash
# Audit Memory System capabilities

MEMORY_MANAGER="${HOME}/.claude/hooks/memory-manager.sh"
DEBUG_ORCHESTRATOR="${HOME}/.claude/hooks/debug-orchestrator.sh"
BUG_FIX_DB="${HOME}/.claude/.debug/bug-fixes.jsonl"
mkdir -p "$(dirname "$BUG_FIX_DB")"

echo "=== 1. Audit Context Saving (Memory Manager) ==="
# Test checkpoint creation
CHECKPOINT_ID=$("$MEMORY_MANAGER" checkpoint "Test checkpoint" 2>/dev/null)
echo "Checkpoint ID returned: $CHECKPOINT_ID"

if [[ "$CHECKPOINT_ID" == "MEM-12345" ]]; then
    echo "⚠️  CRITICAL: Memory Manager is returning a hardcoded STUB ID."
    echo "   Context is NOT being saved persistently."
else
    echo "✓ Memory Manager returned unique ID."
fi

echo "=== 2. Audit Fix Retrieval (Debug Orchestrator) ==="
# 1. Clear DB
echo "" > "$BUG_FIX_DB"

# 2. Record a specific fix
echo "Recording a test fix..."
"$DEBUG_ORCHESTRATOR" record-fix \
    "Python loop error" \
    "syntax" \
    "Fixed indentation in loop" \
    "main.py" \
    "true" \
    "passed" >/dev/null

# 3. Search for it using "fuzzy" terms
echo "Searching for 'loop indentation'..."
RESULTS=$("$DEBUG_ORCHESTRATOR" search-similar "loop indentation" 1)
COUNT=$(echo "$RESULTS" | jq '.count')

if [[ "$COUNT" -gt 0 ]]; then
    echo "✓ Fix retrieval works (Global Memory confirmed)."
    echo "   Retrieved: $(echo "$RESULTS" | jq -r '.similar_fixes[0].fix_description')"
else
    echo "✗ Fix retrieval FAILED to find relevant fix."
fi

# 4. Hallucination Check - Recurring Error
# If we record a FAILED fix, does search return it?
echo "Recording a FAILED fix..."
"$DEBUG_ORCHESTRATOR" record-fix \
    "Complex recursion bug" \
    "logic" \
    "Increased stack size" \
    "config.json" \
    "false" \
    "failed" >/dev/null

echo "Searching for 'recursion'..."
RECURSION_RESULTS=$("$DEBUG_ORCHESTRATOR" search-similar "recursion" 5)
# Check if fails are filtered out (they SHOULD be for 'solutions', but maybe we want to know what NOT to do?)
FAILED_IN_RESULTS=$(echo "$RECURSION_RESULTS" | jq '.similar_fixes[] | select(.success == false) | length')

if [[ -z "$FAILED_IN_RESULTS" ]]; then
    echo "✓ Search correctly filters out FAILED fixes (avoids recommending bad ideas)."
else
    echo "⚠️  Search returns FAILED fixes. Agent might hallucinate that this is a solution."
fi

echo "=== Audit Complete ==="
