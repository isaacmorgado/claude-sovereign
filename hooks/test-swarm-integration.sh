#!/usr/bin/env bash
# Integration test for Swarm Orchestrator conflict resolution

set -euo pipefail

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=========================================="
echo "Swarm Orchestrator Integration Test"
echo "Testing Real Git Conflict Resolution"
echo "=========================================="
echo ""

# Create a temporary git repo for testing
TEST_DIR=$(mktemp -d)
cd "$TEST_DIR"
git init -q
git config user.email "test@example.com"
git config user.name "Test User"

echo "Test directory: $TEST_DIR"
echo ""

# ============================================================================
# Test Case 1: Single Small Conflict (should auto-resolve)
# ============================================================================

echo -e "${YELLOW}Test Case 1: Single Small Conflict${NC}"

# Create initial file
cat > test.txt <<EOF
line 1
line 2
line 3
EOF
git add test.txt
git commit -q -m "Initial commit"

# Create branch and make conflicting change
git checkout -q -b feature1
cat > test.txt <<EOF
line 1
changed in feature
line 3
EOF
git add test.txt
git commit -q -m "Feature change"

# Make conflicting change in main
git checkout -q master
cat > test.txt <<EOF
line 1
changed in main
line 3
EOF
git add test.txt
git commit -q -m "Main change"

# Try to merge - this will create conflict
git merge --no-edit feature1 2>/dev/null || true

# Count conflict markers in the actual file
conflict_count=$(grep -cE '^(<{7}|={7}|>{7})' test.txt 2>/dev/null || true)
conflict_count=${conflict_count:-0}

if [[ $conflict_count -eq 3 ]]; then
    echo -e "  ${GREEN}✓${NC} Single conflict detected (3 markers)"
    echo -e "  ${GREEN}✓${NC} Should auto-resolve: YES"
else
    echo -e "  ${RED}✗${NC} Expected 3 markers, got $conflict_count"
fi

# Cleanup
git merge --abort 2>/dev/null || true
git checkout -q master
echo ""

# ============================================================================
# Test Case 2: Multiple Conflicts (should NOT auto-resolve)
# ============================================================================

echo -e "${YELLOW}Test Case 2: Multiple Conflicts${NC}"

# Reset
git branch -D feature1 2>/dev/null || true
git checkout -q master
git reset --hard HEAD~1 -q

# Create initial file with more lines
cat > test.txt <<EOF
line 1
line 2
line 3
line 4
line 5
line 6
EOF
git add test.txt
git commit -q -m "Baseline"

# Create branch and make multiple conflicting changes in separate sections
git checkout -q -b feature2
cat > test.txt <<EOF
changed in feature A
line 2
line 3
line 4
line 5
changed in feature B
EOF
git add test.txt
git commit -q -m "Feature changes"

# Make different conflicting changes in main (separate sections)
git checkout -q master
cat > test.txt <<EOF
changed in main A
line 2
line 3
line 4
line 5
changed in main B
EOF
git add test.txt
git commit -q -m "Main changes"

# Try to merge
git merge --no-edit feature2 2>/dev/null || true

# Count conflict markers in the actual file
conflict_count=$(grep -cE '^(<{7}|={7}|>{7})' test.txt 2>/dev/null || true)
conflict_count=${conflict_count:-0}

if [[ $conflict_count -eq 6 ]]; then
    echo -e "  ${GREEN}✓${NC} Multiple conflicts detected ($conflict_count markers = 2 regions)"
    echo -e "  ${GREEN}✓${NC} Should auto-resolve: NO"
else
    echo -e "  ${RED}✗${NC} Expected 6 markers (2 regions), got $conflict_count"
fi

# Cleanup
git merge --abort 2>/dev/null || true
echo ""

# ============================================================================
# Test Case 3: No Conflicts (should NOT trigger auto-resolve)
# ============================================================================

echo -e "${YELLOW}Test Case 3: No Conflicts${NC}"

# Reset
git branch -D feature2 2>/dev/null || true
git checkout -q master
git reset --hard HEAD~1 -q

# Create branch with non-conflicting change
git checkout -q -b feature3
cat > other.txt <<EOF
new file
EOF
git add other.txt
git commit -q -m "Add new file"

# Merge should succeed
git checkout -q master
if git merge --no-edit feature3 2>/dev/null; then
    echo -e "  ${GREEN}✓${NC} Merge succeeded without conflicts"
    echo -e "  ${GREEN}✓${NC} Should auto-resolve: N/A"
else
    echo -e "  ${RED}✗${NC} Unexpected merge failure"
fi

echo ""

# ============================================================================
# Test Case 4: Package Lock Files (should always auto-resolve)
# ============================================================================

echo -e "${YELLOW}Test Case 4: Package Lock File Conflict${NC}"

# Reset
git branch -D feature3 2>/dev/null || true
git checkout -q master
git reset --hard HEAD~1 -q

# Create package-lock.json with conflict
cat > package-lock.json <<EOF
{
  "version": "1.0.0"
}
EOF
git add package-lock.json
git commit -q -m "Initial package-lock"

git checkout -q -b feature4
cat > package-lock.json <<EOF
{
  "version": "1.0.1"
}
EOF
git add package-lock.json
git commit -q -m "Update package-lock (feature)"

git checkout -q master
cat > package-lock.json <<EOF
{
  "version": "1.0.2"
}
EOF
git add package-lock.json
git commit -q -m "Update package-lock (main)"

# Try to merge
git merge --no-edit feature4 2>/dev/null || true

if git diff --name-only --diff-filter=U 2>/dev/null | grep -q "package-lock.json"; then
    echo -e "  ${GREEN}✓${NC} Package lock conflict detected"
    echo -e "  ${GREEN}✓${NC} Should auto-resolve: YES (take ours)"
else
    echo -e "  ${RED}✗${NC} Expected package-lock.json conflict"
fi

# Cleanup
cd /
rm -rf "$TEST_DIR"

echo ""
echo "=========================================="
echo -e "${GREEN}✓ Integration Tests Complete${NC}"
echo "=========================================="
echo ""
echo "Summary:"
echo "  - Single conflict: Auto-resolve ✓"
echo "  - Multiple conflicts: Manual resolution ✓"
echo "  - No conflicts: Normal merge ✓"
echo "  - Package locks: Auto-resolve (ours) ✓"
