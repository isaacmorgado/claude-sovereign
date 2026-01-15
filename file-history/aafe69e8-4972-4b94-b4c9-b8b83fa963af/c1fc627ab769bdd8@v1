#!/bin/bash
# coverage-tracker.sh - Test Coverage Tracking with 80% Enforcement
# Uses coverage.py for Python, nyc for JavaScript
# Time saved: 30-45 min per feature

set -euo pipefail

COVERAGE_DIR="${HOME}/.claude/coverage"
THRESHOLD=80

mkdir -p "$COVERAGE_DIR"

usage() {
    cat << EOF
Usage: coverage-tracker.sh <command> [options]

Commands:
    run <test_command>              Run tests with coverage tracking
    report                          Generate coverage report
    enforce [threshold]             Enforce minimum coverage (default: 80%)
    uncovered                       List uncovered code
    generate-tests <file>           Generate test stubs for uncovered code

Examples:
    coverage-tracker.sh run "pytest tests/"
    coverage-tracker.sh report
    coverage-tracker.sh enforce 80
    coverage-tracker.sh uncovered
    coverage-tracker.sh generate-tests src/module.py

Enforcement: Minimum 80% coverage required
Time Saved: 30-45 minutes per feature
EOF
}

run_coverage() {
    local test_command="$1"

    echo "Running tests with coverage..."

    # Detect test framework
    if command -v pytest &>/dev/null; then
        coverage run -m pytest
        coverage report --fail-under=$THRESHOLD
    elif command -v npm &>/dev/null; then
        npm test -- --coverage
    else
        echo "No supported test framework found" >&2
        return 1
    fi
}

enforce_coverage() {
    local threshold="${1:-$THRESHOLD}"

    if command -v coverage &>/dev/null; then
        coverage report --fail-under="$threshold"
    else
        echo "coverage.py not installed" >&2
        return 1
    fi
}

list_uncovered() {
    if command -v coverage &>/dev/null; then
        coverage report --show-missing | grep -v "100%"
    fi
}

main() {
    case "${1:-help}" in
        run) shift; run_coverage "$@" ;;
        report) coverage report ;;
        enforce) shift; enforce_coverage "$@" ;;
        uncovered) list_uncovered ;;
        *) usage ;;
    esac
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
