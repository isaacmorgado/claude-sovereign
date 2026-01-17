#!/usr/bin/env bash
# Bash Portability Test Script
# Tests all shell scripts for Bash 3.2 (macOS default) compatibility
#
# Usage: ./test-bash-compat.sh [--fix]
# Options:
#   --fix    Automatically fix shebang lines to use /usr/bin/env bash

set -e

# Configuration
HOOKS_DIR="${HOME}/.claude/hooks"
SWARM_DIR="${HOME}/.claude/swarm"
COMMANDS_DIR="${HOME}/.claude/commands"
FIX_MODE=false

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m' # No Color

# Counters
TOTAL_SCRIPTS=0
COMPATIBLE_SCRIPTS=0
WARNINGS=0
ERRORS=0

# Parse arguments
if [[ "$1" == "--fix" ]]; then
    FIX_MODE=true
    echo "Running in fix mode - will update shebang lines"
fi

echo "========================================"
echo "Bash Portability Test Suite"
echo "========================================"
echo ""

# Check current bash version
echo "Current Bash Version: $BASH_VERSION"
BASH_MAJOR=$(echo "$BASH_VERSION" | cut -d. -f1)
BASH_MINOR=$(echo "$BASH_VERSION" | cut -d. -f2)
echo "Major: $BASH_MAJOR, Minor: $BASH_MINOR"
echo ""

if [[ $BASH_MAJOR -lt 3 ]]; then
    echo -e "${RED}ERROR: Bash 3.2+ required for this project${NC}"
    exit 1
fi

# Function to check a single script
check_script() {
    local file="$1"
    local has_issues=false
    local issues=""

    TOTAL_SCRIPTS=$((TOTAL_SCRIPTS + 1))

    # Check 1: Shebang portability
    local shebang
    shebang=$(head -n1 "$file")
    if [[ "$shebang" == "#!/bin/bash" ]]; then
        issues="${issues}  - Non-portable shebang: ${shebang} (should be #!/usr/bin/env bash)\n"
        has_issues=true

        if [[ "$FIX_MODE" == true ]]; then
            # Fix the shebang
            if [[ "$(uname)" == "Darwin" ]]; then
                # macOS sed requires empty string for -i
                sed -i '' '1s|#!/bin/bash|#!/usr/bin/env bash|' "$file"
            else
                # GNU sed
                sed -i '1s|#!/bin/bash|#!/usr/bin/env bash|' "$file"
            fi
            issues="${issues}    -> FIXED\n"
        fi
    fi

    # Check 2: Associative arrays (Bash 4+)
    if grep -qE 'declare\s+-A' "$file" 2>/dev/null; then
        issues="${issues}  - Uses associative arrays (declare -A) - requires Bash 4+\n"
        has_issues=true
        ERRORS=$((ERRORS + 1))
    fi

    # Check 3: Case modification (Bash 4+)
    if grep -qE '\$\{[^}]*,,\}|\$\{[^}]*\^\^\}' "$file" 2>/dev/null; then
        issues="${issues}  - Uses case modification (\${var,,} or \${var^^}) - requires Bash 4+\n"
        has_issues=true
        ERRORS=$((ERRORS + 1))
    fi

    # Check 4: |& pipe stderr (Bash 4+)
    if grep -qE '\|\&[^&]' "$file" 2>/dev/null; then
        issues="${issues}  - Uses |& for stderr piping - requires Bash 4+\n"
        has_issues=true
        ERRORS=$((ERRORS + 1))
    fi

    # Check 5: mapfile/readarray (Bash 4+)
    if grep -qE '\b(mapfile|readarray)\b' "$file" 2>/dev/null; then
        issues="${issues}  - Uses mapfile/readarray - requires Bash 4+\n"
        has_issues=true
        ERRORS=$((ERRORS + 1))
    fi

    # Check 6: coproc (Bash 4+)
    if grep -qE '^\s*coproc\b' "$file" 2>/dev/null; then
        issues="${issues}  - Uses coproc - requires Bash 4+\n"
        has_issues=true
        ERRORS=$((ERRORS + 1))
    fi

    # Check 7: &>> append redirect (Bash 4+)
    if grep -qE '&>>' "$file" 2>/dev/null; then
        issues="${issues}  - Uses &>> redirect - requires Bash 4+\n"
        has_issues=true
        ERRORS=$((ERRORS + 1))
    fi

    # Check 8: $'' ANSI-C quoting with \u or \U (Bash 4.2+)
    if grep -qE "\$'[^']*\\\\[uU][0-9a-fA-F]" "$file" 2>/dev/null; then
        issues="${issues}  - Uses \\u or \\U in \$'' quoting - requires Bash 4.2+\n"
        has_issues=true
        ERRORS=$((ERRORS + 1))
    fi

    # Report results
    if [[ "$has_issues" == true ]]; then
        echo -e "${YELLOW}$(basename "$file")${NC}"
        echo -e "$issues"
        WARNINGS=$((WARNINGS + 1))
    else
        echo -e "${GREEN}[PASS]${NC} $(basename "$file")"
        COMPATIBLE_SCRIPTS=$((COMPATIBLE_SCRIPTS + 1))
    fi
}

# Function to scan a directory
scan_directory() {
    local dir="$1"
    local label="$2"

    if [[ ! -d "$dir" ]]; then
        echo "Directory not found: $dir"
        return
    fi

    echo ""
    echo "----------------------------------------"
    echo "Scanning: $label"
    echo "Path: $dir"
    echo "----------------------------------------"

    local count=0
    while IFS= read -r -d '' file; do
        # Skip backup files
        if [[ "$file" == *.backup ]]; then
            continue
        fi
        check_script "$file"
        count=$((count + 1))
    done < <(find "$dir" -maxdepth 1 -name "*.sh" -type f -print0 2>/dev/null)

    if [[ $count -eq 0 ]]; then
        echo "No .sh files found"
    fi
}

# Scan all directories
scan_directory "$HOOKS_DIR" "Hooks Directory"
scan_directory "$SWARM_DIR" "Swarm Directory"

echo ""
echo "========================================"
echo "Summary"
echo "========================================"
echo "Total scripts checked: $TOTAL_SCRIPTS"
echo -e "${GREEN}Compatible scripts: $COMPATIBLE_SCRIPTS${NC}"
echo -e "${YELLOW}Scripts with warnings: $WARNINGS${NC}"
echo -e "${RED}Critical errors (Bash 4+ required): $ERRORS${NC}"
echo ""

if [[ $ERRORS -gt 0 ]]; then
    echo -e "${RED}FAIL: Some scripts require Bash 4+ features${NC}"
    echo "These scripts will not work on macOS default bash"
    exit 1
elif [[ $WARNINGS -gt 0 ]] && [[ "$FIX_MODE" != true ]]; then
    echo -e "${YELLOW}WARNING: Some scripts have non-portable shebangs${NC}"
    echo "Run with --fix to automatically update them"
    exit 0
else
    echo -e "${GREEN}PASS: All scripts are Bash 3.2+ compatible${NC}"
    exit 0
fi
