#!/bin/bash
# Proactive Janitor Hook
# Scans for maintenance tasks (tech debt, security, stale code)
# Returns a focused summary for the agent to tackle next.

set -uo pipefail

# Configuration
DEBT_PATTERN="FIXME|TODO:URGENT|HACK:"
STALE_DAYS=14
OUT_FILE="${HOME}/.claude/janitor-report.md"

report() {
    echo "$1"
}

# 1. Tech Debt Scan
debt_count=$(grep -rE "$DEBT_PATTERN" . --exclude-dir=node_modules --exclude-dir=.git 2>/dev/null | head -n 5)
debt_total=$(grep -rE "$DEBT_PATTERN" . --exclude-dir=node_modules --exclude-dir=.git 2>/dev/null | wc -l)

DEBT_REPORT=""
if [[ "$debt_total" -gt 0 ]]; then
    DEBT_REPORT="
**Tech Debt**: Found $debt_total issues (showing top 5):
$debt_count"
fi

# 2. Security Scan (Node.js)
SECURITY_REPORT=""
if [[ -f "package.json" ]]; then
    if command -v npm >/dev/null 2>&1; then
        # Check for High/Critical only
        audit_summary=$(npm audit --json 2>/dev/null | jq -r '.metadata.vulnerabilities | select(.high > 0 or .critical > 0) | "High: \(.high), Critical: \(.critical)"' 2>/dev/null || echo "")
        
        if [[ -n "$audit_summary" ]]; then
            SECURITY_REPORT="
**Security Alert**: $audit_summary. Run \`npm audit fix\`."
        fi
    fi
fi

# 3. Stale Branch Scan (Git)
BRANCH_REPORT=""
if [[ -d ".git" ]]; then
    # Find local branches not touched in STALE_DAYS
    stale_branches=$(git for-each-ref --sort=-committerdate --format='%(committerdate:relative)|%(refname:short)' refs/heads/ | \
        awk -v days="$STALE_DAYS" -F'|' '
        $1 ~ /year|month/ { print $2; next }
        $1 ~ /week/ { 
            split($1, a, " "); 
            if (a[1] > 2) print $2 
        }' | head -n 3)
        
    if [[ -n "$stale_branches" ]]; then
        BRANCH_REPORT="
**Stale Branches**: Consider cleaning up:
$stale_branches"
    fi
fi

# Combine Reports
FULL_REPORT="${DEBT_REPORT}${SECURITY_REPORT}${BRANCH_REPORT}"

if [[ -n "$FULL_REPORT" ]]; then
    echo "🧹 **Proactive Janitor Report**:$FULL_REPORT"
fi
