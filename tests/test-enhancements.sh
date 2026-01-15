#!/bin/bash
# Test suite for all 8 enhancements

set -euo pipefail

echo "Testing Memory System Enhancements..."
echo "======================================"

# Test 1: AST Chunker
echo "[1/8] Testing AST Chunker..."
if ~/.claude/hooks/ast-chunker.sh help &>/dev/null; then
    echo "✓ AST Chunker is executable and responsive"
else
    echo "✗ AST Chunker failed"
    exit 1
fi

# Test 2: Token Budgeter
echo "[2/8] Testing Token Budgeter..."
if ~/.claude/hooks/token-budgeter.sh status &>/dev/null; then
    echo "✓ Token Budgeter is executable and responsive"
else
    echo "✗ Token Budgeter failed"
    exit 1
fi

# Test 3: SQLite Migrator
echo "[3/8] Testing SQLite Migrator..."
if ~/.claude/hooks/sqlite-migrator.sh help &>/dev/null; then
    echo "✓ SQLite Migrator is executable and responsive"
else
    echo "✗ SQLite Migrator failed"
    exit 1
fi

# Test 4: Vector Embedder
echo "[4/8] Testing Vector Embedder..."
if ~/.claude/hooks/vector-embedder.sh help &>/dev/null; then
    echo "✓ Vector Embedder is executable and responsive"
else
    echo "✗ Vector Embedder failed"
    exit 1
fi

# Test 5: Performance Profiler
echo "[5/8] Testing Performance Profiler..."
if ~/.claude/hooks/performance-profiler.sh help &>/dev/null; then
    echo "✓ Performance Profiler is executable and responsive"
else
    echo "✗ Performance Profiler failed"
    exit 1
fi

# Test 6: Coverage Tracker
echo "[6/8] Testing Coverage Tracker..."
if ~/.claude/hooks/coverage-tracker.sh help &>/dev/null; then
    echo "✓ Coverage Tracker is executable and responsive"
else
    echo "✗ Coverage Tracker failed"
    exit 1
fi

# Test 7: Vulnerability Scanner
echo "[7/8] Testing Vulnerability Scanner..."
if ~/.claude/hooks/vuln-scanner.sh help &>/dev/null; then
    echo "✓ Vulnerability Scanner is executable and responsive"
else
    echo "✗ Vulnerability Scanner failed"
    exit 1
fi

# Test 8: Code Quality
echo "[8/8] Testing Code Quality..."
if ~/.claude/hooks/code-quality.sh help &>/dev/null; then
    echo "✓ Code Quality is executable and responsive"
else
    echo "✗ Code Quality failed"
    exit 1
fi

echo ""
echo "======================================"
echo "✅ All 8 enhancements passed basic tests"
echo ""
echo "Next steps:"
echo "1. Install Python dependencies: pip install tree-sitter-languages tiktoken sentence-transformers coverage pip-audit"
echo "2. Install Node.js dependencies: npm install -g jscpd dependency-cruiser"
echo "3. Test individual features with real data"
echo "4. Review documentation: ~/.claude/docs/ENHANCEMENTS-INTEGRATION.md"
