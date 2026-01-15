#!/bin/bash
# Run ReflexionAgent edge case tests sequentially with delays
# to avoid rate limit issues

set -e

echo "🧪 Running ReflexionAgent Edge Case Tests Sequentially"
echo "=============================================="
echo ""

# Test 1: Complex REST API (30-40 iterations)
echo "📝 Running EDGE CASE 1: Complex REST API..."
bun test tests/agents/reflexion-edge-cases.test.ts --test-name "EDGE CASE 1" --test-timeout 600000
echo "✅ EDGE CASE 1 complete"
echo ""
echo "⏱️  Waiting 30s before next test to avoid rate limits..."
sleep 30
echo ""

# Test 2: Algorithm Implementation (25-35 iterations)
echo "📝 Running EDGE CASE 2: Algorithm Implementation..."
bun test tests/agents/reflexion-edge-cases.test.ts --test-name "EDGE CASE 2" --test-timeout 600000
echo "✅ EDGE CASE 2 complete"
echo ""
echo "⏱️  Waiting 30s before next test to avoid rate limits..."
sleep 30
echo ""

# Test 3: Full-Stack Project (40-50 iterations)
echo "📝 Running EDGE CASE 3: Full-Stack Project..."
bun test tests/agents/reflexion-edge-cases.test.ts --test-name "EDGE CASE 3" --test-timeout 600000
echo "✅ EDGE CASE 3 complete"
echo ""
echo "⏱️  Waiting 30s before next test to avoid rate limits..."
sleep 30
echo ""

# Test 4: Error Recovery (20-30 iterations)
echo "📝 Running EDGE CASE 4: Error Recovery..."
bun test tests/agents/reflexion-edge-cases.test.ts --test-name "EDGE CASE 4" --test-timeout 600000
echo "✅ EDGE CASE 4 complete"
echo ""

echo "=============================================="
echo "🎉 All edge case tests complete!"
echo ""
echo "📊 See REFLEXION-EDGE-CASE-TEST-RESULTS.md for detailed results"
