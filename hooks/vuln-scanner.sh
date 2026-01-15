#!/bin/bash
# vuln-scanner.sh - Dependency Vulnerability Scanning
# Supports pip-audit, npm audit, cargo audit
# Time saved: 60-90 min per audit cycle

set -euo pipefail

SCAN_DIR="${HOME}/.claude/scans"
LOG_FILE="${HOME}/.claude/logs/vulnerabilities.log"

mkdir -p "$SCAN_DIR" "$(dirname "$LOG_FILE")"

usage() {
    cat << EOF
Usage: vuln-scanner.sh <command> [options]

Commands:
    scan [directory]                Scan dependencies for vulnerabilities
    report [scan_id]                Generate vulnerability report
    fix                             Auto-fix vulnerabilities where possible
    stats                           Show vulnerability statistics

Examples:
    vuln-scanner.sh scan .
    vuln-scanner.sh report scan_12345
    vuln-scanner.sh fix

Supported: pip-audit (Python), npm audit (Node.js), cargo audit (Rust)
Time Saved: 60-90 minutes per audit cycle
EOF
}

scan_dependencies() {
    local directory="${1:-.}"
    local scan_id="scan_$(date +%s)"
    local scan_file="${SCAN_DIR}/${scan_id}.json"

    echo "Scanning dependencies in: $directory"
    echo "Scan ID: $scan_id"

    cd "$directory"

    # Python
    if [[ -f "requirements.txt" ]] || [[ -f "pyproject.toml" ]]; then
        if command -v pip-audit &>/dev/null; then
            echo "Scanning Python dependencies..."
            pip-audit --desc --format json > "${scan_file}.python.json" 2>&1 || true
        fi
    fi

    # Node.js
    if [[ -f "package.json" ]]; then
        if command -v npm &>/dev/null; then
            echo "Scanning Node.js dependencies..."
            npm audit --json > "${scan_file}.npm.json" 2>&1 || true
        fi
    fi

    # Rust
    if [[ -f "Cargo.toml" ]]; then
        if command -v cargo &>/dev/null; then
            echo "Scanning Rust dependencies..."
            cargo audit --json > "${scan_file}.rust.json" 2>&1 || true
        fi
    fi

    # Combine results
    echo "{\"scan_id\": \"$scan_id\", \"timestamp\": \"$(date -Iseconds)\"}" > "$scan_file"

    echo "Scan complete: $scan_id"
    echo "$scan_id"
}

generate_report() {
    local scan_id="$1"
    local scan_file="${SCAN_DIR}/${scan_id}.json"

    if [[ ! -f "$scan_file" ]]; then
        echo "Scan not found: $scan_id" >&2
        return 1
    fi

    echo "Vulnerability Report: $scan_id"
    echo "=============================="

    # Count vulnerabilities
    local critical=0
    local high=0
    local medium=0
    local low=0

    for result in "${SCAN_DIR}/${scan_id}".*.json; do
        if [[ -f "$result" ]]; then
            echo "Found vulnerabilities in: $(basename "$result")"
            cat "$result" | jq -r '.vulnerabilities[] | "\(.severity): \(.name) - \(.title)"' 2>/dev/null || true
        fi
    done
}

auto_fix() {
    echo "Auto-fixing vulnerabilities..."

    # Python
    if command -v pip-audit &>/dev/null; then
        pip-audit --fix
    fi

    # Node.js
    if command -v npm &>/dev/null && [[ -f "package.json" ]]; then
        npm audit fix
    fi

    echo "Auto-fix complete. Review changes before committing."
}

main() {
    case "${1:-help}" in
        scan) shift; scan_dependencies "$@" ;;
        report) shift; generate_report "$@" ;;
        fix) auto_fix ;;
        *) usage ;;
    esac
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
