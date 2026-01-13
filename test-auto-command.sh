#!/bin/bash
# Test the /auto command

echo "Testing /auto command..."
echo ""

# Test 1: Help flag
echo "Test 1: Help flag"
bun src/index.ts auto --help
echo ""

# Test 2: Simple goal (dry run - will timeout but should show initialization)
echo "Test 2: Initialize with simple goal (will ctrl+c after seeing it start)"
echo "Command: bun src/index.ts auto 'write hello world to test.txt' -i 2 -v"
echo ""
echo "Press Ctrl+C after verifying initialization works..."
echo ""

# Note: We won't actually run this in the script because it requires API key
# and will take time. Instead, show what the user should test manually:
echo "Manual test required:"
echo "  bun src/index.ts auto 'list files in current directory' -i 3 -v"
echo ""
echo "Expected behavior:"
echo "  1. Shows 'Autonomous mode activated'"
echo "  2. Displays goal"
echo "  3. Starts ReAct+Reflexion loop"
echo "  4. Shows iteration progress"
echo "  5. Uses memory system (checkpoints, episodes)"
echo ""
