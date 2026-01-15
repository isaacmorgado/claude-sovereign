#!/bin/bash
# Code Quality System - Comprehensive code quality checks
# Based on patterns from: rovo-dev CodeQualityCheckTool, various linting frameworks

set -uo pipefail

QUALITY_DIR="${HOME}/.claude/quality"
REPORT_FILE="$QUALITY_DIR/report.json"
LOG_FILE="${HOME}/.claude/code-quality.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

init_quality() {
    mkdir -p "$QUALITY_DIR"
}

# =============================================================================
# PROJECT DETECTION
# =============================================================================

detect_project_type() {
    local dir="${1:-.}"

    if [[ -f "$dir/package.json" ]]; then
        if grep -q "typescript" "$dir/package.json" 2>/dev/null; then
            echo "typescript"
        else
            echo "javascript"
        fi
    elif [[ -f "$dir/pyproject.toml" ]] || [[ -f "$dir/requirements.txt" ]]; then
        echo "python"
    elif [[ -f "$dir/go.mod" ]]; then
        echo "go"
    elif [[ -f "$dir/Cargo.toml" ]]; then
        echo "rust"
    elif [[ -f "$dir/build.gradle" ]] || [[ -f "$dir/pom.xml" ]]; then
        echo "java"
    else
        echo "unknown"
    fi
}

# =============================================================================
# LINT CHECKS
# =============================================================================

run_lint() {
    local dir="${1:-.}"
    local project_type
    project_type=$(detect_project_type "$dir")

    local result=""
    local exit_code=0

    log "Running lint for $project_type project in $dir"

    case "$project_type" in
        typescript|javascript)
            if [[ -f "$dir/package.json" ]]; then
                if grep -q '"lint"' "$dir/package.json" 2>/dev/null; then
                    result=$(cd "$dir" && npm run lint 2>&1) || exit_code=$?
                elif command -v eslint &>/dev/null; then
                    result=$(cd "$dir" && eslint . --ext .ts,.tsx,.js,.jsx 2>&1) || exit_code=$?
                fi
            fi
            ;;
        python)
            if command -v ruff &>/dev/null; then
                result=$(cd "$dir" && ruff check . 2>&1) || exit_code=$?
            elif command -v pylint &>/dev/null; then
                result=$(cd "$dir" && pylint **/*.py 2>&1) || exit_code=$?
            elif command -v flake8 &>/dev/null; then
                result=$(cd "$dir" && flake8 . 2>&1) || exit_code=$?
            fi
            ;;
        go)
            result=$(cd "$dir" && go vet ./... 2>&1) || exit_code=$?
            if command -v staticcheck &>/dev/null; then
                result+=$'\n'$(cd "$dir" && staticcheck ./... 2>&1) || exit_code=$?
            fi
            if command -v golangci-lint &>/dev/null; then
                result+=$'\n'$(cd "$dir" && golangci-lint run 2>&1) || exit_code=$?
            fi
            ;;
        rust)
            result=$(cd "$dir" && cargo clippy 2>&1) || exit_code=$?
            ;;
        java)
            if command -v checkstyle &>/dev/null; then
                result=$(cd "$dir" && checkstyle -c /google_checks.xml src/ 2>&1) || exit_code=$?
            fi
            ;;
        *)
            result="Unknown project type"
            exit_code=1
            ;;
    esac

    jq -n \
        --arg type "lint" \
        --arg project "$project_type" \
        --argjson passed "$([ $exit_code -eq 0 ] && echo true || echo false)" \
        --arg output "$result" \
        --argjson exitCode "$exit_code" \
        '{type: $type, project: $project, passed: $passed, output: $output, exitCode: $exitCode}'
}

# =============================================================================
# TYPE CHECKS
# =============================================================================

run_typecheck() {
    local dir="${1:-.}"
    local project_type
    project_type=$(detect_project_type "$dir")

    local result=""
    local exit_code=0

    log "Running typecheck for $project_type project in $dir"

    case "$project_type" in
        typescript)
            if [[ -f "$dir/package.json" ]]; then
                if grep -q '"typecheck"' "$dir/package.json" 2>/dev/null; then
                    result=$(cd "$dir" && npm run typecheck 2>&1) || exit_code=$?
                else
                    result=$(cd "$dir" && npx tsc --noEmit 2>&1) || exit_code=$?
                fi
            fi
            ;;
        python)
            if command -v mypy &>/dev/null; then
                result=$(cd "$dir" && mypy . 2>&1) || exit_code=$?
            elif command -v pyright &>/dev/null; then
                result=$(cd "$dir" && pyright 2>&1) || exit_code=$?
            fi
            ;;
        go)
            result=$(cd "$dir" && go build ./... 2>&1) || exit_code=$?
            ;;
        rust)
            result=$(cd "$dir" && cargo check 2>&1) || exit_code=$?
            ;;
        java)
            if [[ -f "$dir/build.gradle" ]]; then
                result=$(cd "$dir" && ./gradlew compileJava 2>&1) || exit_code=$?
            elif [[ -f "$dir/pom.xml" ]]; then
                result=$(cd "$dir" && mvn compile 2>&1) || exit_code=$?
            fi
            ;;
        *)
            result="Type checking not available"
            exit_code=0
            ;;
    esac

    jq -n \
        --arg type "typecheck" \
        --arg project "$project_type" \
        --argjson passed "$([ $exit_code -eq 0 ] && echo true || echo false)" \
        --arg output "$result" \
        --argjson exitCode "$exit_code" \
        '{type: $type, project: $project, passed: $passed, output: $output, exitCode: $exitCode}'
}

# =============================================================================
# SECURITY CHECKS
# =============================================================================

run_security() {
    local dir="${1:-.}"
    local project_type
    project_type=$(detect_project_type "$dir")

    local result=""
    local exit_code=0
    local checks_run=0

    log "Running security checks for $project_type project in $dir"

    # Check for secrets in code
    if command -v gitleaks &>/dev/null; then
        result+="=== Gitleaks ===$'\n'"
        result+=$(cd "$dir" && gitleaks detect --no-git -v 2>&1) || exit_code=$?
        checks_run=$((checks_run + 1))
    fi

    # Language-specific security checks
    case "$project_type" in
        typescript|javascript)
            if [[ -f "$dir/package.json" ]]; then
                result+="$'\n'=== npm audit ===$'\n'"
                result+=$(cd "$dir" && npm audit 2>&1) || exit_code=$?
                checks_run=$((checks_run + 1))
            fi
            ;;
        python)
            if command -v bandit &>/dev/null; then
                result+="$'\n'=== Bandit ===$'\n'"
                result+=$(cd "$dir" && bandit -r . 2>&1) || exit_code=$?
                checks_run=$((checks_run + 1))
            fi
            if command -v safety &>/dev/null && [[ -f "$dir/requirements.txt" ]]; then
                result+="$'\n'=== Safety ===$'\n'"
                result+=$(cd "$dir" && safety check -r requirements.txt 2>&1) || exit_code=$?
                checks_run=$((checks_run + 1))
            fi
            ;;
        go)
            if command -v gosec &>/dev/null; then
                result+="$'\n'=== gosec ===$'\n'"
                result+=$(cd "$dir" && gosec ./... 2>&1) || exit_code=$?
                checks_run=$((checks_run + 1))
            fi
            ;;
        rust)
            if command -v cargo-audit &>/dev/null; then
                result+="$'\n'=== cargo audit ===$'\n'"
                result+=$(cd "$dir" && cargo audit 2>&1) || exit_code=$?
                checks_run=$((checks_run + 1))
            fi
            ;;
    esac

    # Check for common issues
    result+="$'\n'=== Pattern Checks ===$'\n'"

    # Check for hardcoded secrets patterns
    local secret_patterns="(password|secret|api_key|apikey|token|credential)\\s*=\\s*['\"][^'\"]+['\"]"
    local secret_matches
    secret_matches=$(grep -rniE "$secret_patterns" "$dir" --include="*.ts" --include="*.js" --include="*.py" --include="*.go" 2>/dev/null | head -20 || true)

    if [[ -n "$secret_matches" ]]; then
        result+="Potential hardcoded secrets found:$'\n'$secret_matches"
        exit_code=1
    else
        result+="No hardcoded secrets patterns found"
    fi

    jq -n \
        --arg type "security" \
        --arg project "$project_type" \
        --argjson passed "$([ $exit_code -eq 0 ] && echo true || echo false)" \
        --arg output "$result" \
        --argjson exitCode "$exit_code" \
        --argjson checksRun "$checks_run" \
        '{type: $type, project: $project, passed: $passed, output: $output, exitCode: $exitCode, checksRun: $checksRun}'
}

# =============================================================================
# TEST CHECKS
# =============================================================================

run_tests() {
    local dir="${1:-.}"
    local project_type
    project_type=$(detect_project_type "$dir")

    local result=""
    local exit_code=0

    log "Running tests for $project_type project in $dir"

    case "$project_type" in
        typescript|javascript)
            if [[ -f "$dir/package.json" ]]; then
                if grep -q '"test"' "$dir/package.json" 2>/dev/null; then
                    result=$(cd "$dir" && npm test 2>&1) || exit_code=$?
                fi
            fi
            ;;
        python)
            if command -v pytest &>/dev/null; then
                result=$(cd "$dir" && pytest 2>&1) || exit_code=$?
            elif [[ -f "$dir/setup.py" ]]; then
                result=$(cd "$dir" && python setup.py test 2>&1) || exit_code=$?
            fi
            ;;
        go)
            result=$(cd "$dir" && go test ./... -v 2>&1) || exit_code=$?
            ;;
        rust)
            result=$(cd "$dir" && cargo test 2>&1) || exit_code=$?
            ;;
        java)
            if [[ -f "$dir/build.gradle" ]]; then
                result=$(cd "$dir" && ./gradlew test 2>&1) || exit_code=$?
            elif [[ -f "$dir/pom.xml" ]]; then
                result=$(cd "$dir" && mvn test 2>&1) || exit_code=$?
            fi
            ;;
        *)
            result="Test framework not detected"
            exit_code=0
            ;;
    esac

    jq -n \
        --arg type "tests" \
        --arg project "$project_type" \
        --argjson passed "$([ $exit_code -eq 0 ] && echo true || echo false)" \
        --arg output "$result" \
        --argjson exitCode "$exit_code" \
        '{type: $type, project: $project, passed: $passed, output: $output, exitCode: $exitCode}'
}

# =============================================================================
# COMPLEXITY ANALYSIS
# =============================================================================

run_complexity() {
    local dir="${1:-.}"
    local project_type
    project_type=$(detect_project_type "$dir")

    local result=""
    local exit_code=0

    log "Running complexity analysis for $project_type project in $dir"

    case "$project_type" in
        typescript|javascript)
            if command -v npx &>/dev/null; then
                # Try to run complexity analysis
                result="Complexity analysis (file count and size):$'\n'"
                result+=$(find "$dir" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null | wc -l | xargs echo "Total files:")
                result+=$'\n'$(find "$dir" -name "*.ts" -o -name "*.tsx" -o -name "*.js" -o -name "*.jsx" 2>/dev/null -exec wc -l {} + 2>/dev/null | tail -1 | xargs echo "Total lines:")
            fi
            ;;
        python)
            if command -v radon &>/dev/null; then
                result=$(cd "$dir" && radon cc . -a -s 2>&1) || exit_code=$?
            else
                result="Complexity analysis (file count and size):$'\n'"
                result+=$(find "$dir" -name "*.py" 2>/dev/null | wc -l | xargs echo "Total files:")
                result+=$'\n'$(find "$dir" -name "*.py" 2>/dev/null -exec wc -l {} + 2>/dev/null | tail -1 | xargs echo "Total lines:")
            fi
            ;;
        go)
            if command -v gocyclo &>/dev/null; then
                result=$(cd "$dir" && gocyclo -over 10 . 2>&1) || exit_code=$?
            else
                result="Complexity analysis (file count and size):$'\n'"
                result+=$(find "$dir" -name "*.go" 2>/dev/null | wc -l | xargs echo "Total files:")
            fi
            ;;
        *)
            result="Complexity analysis not available for $project_type"
            ;;
    esac

    jq -n \
        --arg type "complexity" \
        --arg project "$project_type" \
        --argjson passed "$([ $exit_code -eq 0 ] && echo true || echo false)" \
        --arg output "$result" \
        --argjson exitCode "$exit_code" \
        '{type: $type, project: $project, passed: $passed, output: $output, exitCode: $exitCode}'
}

# =============================================================================
# FULL QUALITY CHECK
# =============================================================================

run_full_check() {
    local dir="${1:-.}"

    init_quality

    log "Running full quality check in $dir"

    local timestamp
    timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    local project_type
    project_type=$(detect_project_type "$dir")

    # Run all checks
    local lint_result
    lint_result=$(run_lint "$dir")

    local type_result
    type_result=$(run_typecheck "$dir")

    local security_result
    security_result=$(run_security "$dir")

    local test_result
    test_result=$(run_tests "$dir")

    local complexity_result
    complexity_result=$(run_complexity "$dir")

    # Calculate overall score
    local passed_count=0
    local total_count=5

    [[ $(echo "$lint_result" | jq -r '.passed') == "true" ]] && passed_count=$((passed_count + 1))
    [[ $(echo "$type_result" | jq -r '.passed') == "true" ]] && passed_count=$((passed_count + 1))
    [[ $(echo "$security_result" | jq -r '.passed') == "true" ]] && passed_count=$((passed_count + 1))
    [[ $(echo "$test_result" | jq -r '.passed') == "true" ]] && passed_count=$((passed_count + 1))
    [[ $(echo "$complexity_result" | jq -r '.passed') == "true" ]] && passed_count=$((passed_count + 1))

    local score
    score=$(echo "scale=2; $passed_count / $total_count * 100" | bc)

    # Generate report
    jq -n \
        --arg timestamp "$timestamp" \
        --arg project "$project_type" \
        --arg dir "$dir" \
        --argjson score "$score" \
        --argjson passed "$passed_count" \
        --argjson total "$total_count" \
        --argjson lint "$lint_result" \
        --argjson typecheck "$type_result" \
        --argjson security "$security_result" \
        --argjson tests "$test_result" \
        --argjson complexity "$complexity_result" \
        '{
            timestamp: $timestamp,
            project: $project,
            directory: $dir,
            score: $score,
            summary: {
                passed: $passed,
                total: $total
            },
            checks: {
                lint: $lint,
                typecheck: $typecheck,
                security: $security,
                tests: $tests,
                complexity: $complexity
            }
        }' | tee "$REPORT_FILE"

    log "Full check complete. Score: $score%"
}

# Get quality summary
get_summary() {
    if [[ ! -f "$REPORT_FILE" ]]; then
        echo "No quality report found. Run 'full' first."
        return 1
    fi

    jq -r '
        "=== Code Quality Report ===\n" +
        "Project: \(.project)\n" +
        "Score: \(.score)%\n" +
        "Passed: \(.summary.passed)/\(.summary.total)\n" +
        "\n--- Check Results ---\n" +
        "Lint: \(if .checks.lint.passed then "✓" else "✗" end)\n" +
        "Types: \(if .checks.typecheck.passed then "✓" else "✗" end)\n" +
        "Security: \(if .checks.security.passed then "✓" else "✗" end)\n" +
        "Tests: \(if .checks.tests.passed then "✓" else "✗" end)\n" +
        "Complexity: \(if .checks.complexity.passed then "✓" else "✗" end)"
    ' "$REPORT_FILE"
}

# =============================================================================
# COMMAND INTERFACE
# =============================================================================

case "${1:-help}" in
    detect)
        detect_project_type "${2:-.}"
        ;;
    lint)
        run_lint "${2:-.}"
        ;;
    typecheck)
        run_typecheck "${2:-.}"
        ;;
    security)
        run_security "${2:-.}"
        ;;
    tests)
        run_tests "${2:-.}"
        ;;
    complexity)
        run_complexity "${2:-.}"
        ;;
    full)
        run_full_check "${2:-.}"
        ;;
    summary)
        get_summary
        ;;
    help|*)
        echo "Code Quality System"
        echo ""
        echo "Usage: $0 <command> [directory]"
        echo ""
        echo "Commands:"
        echo "  detect [dir]      - Detect project type"
        echo "  lint [dir]        - Run linting"
        echo "  typecheck [dir]   - Run type checking"
        echo "  security [dir]    - Run security checks"
        echo "  tests [dir]       - Run tests"
        echo "  complexity [dir]  - Run complexity analysis"
        echo "  full [dir]        - Run all checks"
        echo "  summary           - Show last report summary"
        echo ""
        echo "Supported Projects:"
        echo "  TypeScript/JavaScript (npm, eslint)"
        echo "  Python (ruff, pylint, mypy, pytest, bandit)"
        echo "  Go (go vet, staticcheck, gosec)"
        echo "  Rust (cargo clippy, cargo audit)"
        echo "  Java (gradle, maven, checkstyle)"
        ;;
esac
