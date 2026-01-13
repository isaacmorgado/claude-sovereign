#!/bin/bash
# Test runner with automatic logging
# Captures all test output to timestamped log files

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Create test-results directory if it doesn't exist
mkdir -p test-results

# Generate timestamp for log file
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
LOG_FILE="test-results/test-auto-${TIMESTAMP}.log"

# Display header
echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}Running Test Suite with Logging${NC}"
echo -e "${BLUE}========================================${NC}"
echo -e "${YELLOW}Log file: ${LOG_FILE}${NC}"
echo ""

# Run tests and capture output
bun run test-auto-features.test.ts 2>&1 | tee "${LOG_FILE}"

# Check exit code
TEST_EXIT_CODE=${PIPESTATUS[0]}

echo ""
echo -e "${BLUE}========================================${NC}"
if [ $TEST_EXIT_CODE -eq 0 ]; then
    echo -e "${GREEN}✓ Tests completed successfully${NC}"
    echo -e "${GREEN}Log saved to: ${LOG_FILE}${NC}"
else
    echo -e "${RED}✗ Tests failed with exit code ${TEST_EXIT_CODE}${NC}"
    echo -e "${YELLOW}Check log file for details: ${LOG_FILE}${NC}"
fi
echo -e "${BLUE}========================================${NC}"

# List recent log files
echo ""
echo -e "${BLUE}Recent test logs:${NC}"
ls -lt test-results/test-auto-*.log | head -5 | awk '{print "  " $9 " (" $6 " " $7 " " $8 ")"}'

exit $TEST_EXIT_CODE
