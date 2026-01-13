#!/bin/bash
# Reverse Engineering Analyzer - Analyze code patterns
# Identifies patterns, anti-patterns, and architectural insights

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.claude/logs/re-analyze.log"
OUTPUT_DIR="${HOME}/.claude/reverse-engineering"

mkdir -p "$(dirname "$LOG_FILE")"
mkdir -p "$OUTPUT_DIR"

log() {
    local timestamp
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    echo "[$timestamp] $*" >> "$LOG_FILE"
}

# ============================================================================
# Pattern Detection
# ============================================================================

detect_design_patterns() {
    local target_dir="${1:-.}"
    log "Detecting design patterns in: $target_dir"

    local patterns_found="[]"

    # Singleton pattern
    if grep -r "getInstance\|private.*static.*instance" "$target_dir" 2>/dev/null | head -3 | grep -q .; then
        patterns_found=$(echo "$patterns_found" | jq '. + ["Singleton"]' 2>/dev/null || echo '["Singleton"]')
        log "Found: Singleton pattern"
    fi

    # Factory pattern
    if grep -r "create.*Factory\|Factory.*create" "$target_dir" 2>/dev/null | head -3 | grep -q .; then
        patterns_found=$(echo "$patterns_found" | jq '. + ["Factory"]' 2>/dev/null || echo '["Factory"]')
        log "Found: Factory pattern"
    fi

    # Observer pattern
    if grep -r "subscribe\|unsubscribe\|notify\|addEventListener" "$target_dir" 2>/dev/null | head -3 | grep -q .; then
        patterns_found=$(echo "$patterns_found" | jq '. + ["Observer"]' 2>/dev/null || echo '["Observer"]')
        log "Found: Observer pattern"
    fi

    # Strategy pattern
    if grep -r "Strategy\|executeStrategy\|setStrategy" "$target_dir" 2>/dev/null | head -3 | grep -q .; then
        patterns_found=$(echo "$patterns_found" | jq '. + ["Strategy"]' 2>/dev/null || echo '["Strategy"]')
        log "Found: Strategy pattern"
    fi

    # Builder pattern
    if grep -r "Builder\|build()\|with.*()\|set.*()" "$target_dir" 2>/dev/null | head -3 | grep -q .; then
        patterns_found=$(echo "$patterns_found" | jq '. + ["Builder"]' 2>/dev/null || echo '["Builder"]')
        log "Found: Builder pattern"
    fi

    # Repository pattern
    if grep -r "Repository\|save\|delete\|findById\|findAll" "$target_dir" 2>/dev/null | head -3 | grep -q .; then
        patterns_found=$(echo "$patterns_found" | jq '. + ["Repository"]' 2>/dev/null || echo '["Repository"]')
        log "Found: Repository pattern"
    fi

    # Middleware pattern
    if grep -r "middleware\|next()\|use(" "$target_dir" 2>/dev/null | head -3 | grep -q .; then
        patterns_found=$(echo "$patterns_found" | jq '. + ["Middleware"]' 2>/dev/null || echo '["Middleware"]')
        log "Found: Middleware pattern"
    fi

    echo "$patterns_found"
}

detect_anti_patterns() {
    local target_dir="${1:-.}"
    log "Detecting anti-patterns in: $target_dir"

    local anti_patterns="[]"

    # God object (large files)
    local large_files=$(find "$target_dir" -type f -name "*.ts" -o -name "*.js" -o -name "*.py" -o -name "*.java" 2>/dev/null | \
        xargs wc -l 2>/dev/null | awk '$1 > 500 {print $2}' || true)

    if [[ -n "$large_files" ]]; then
        local large_files_json
        large_files_json=$(echo "$large_files" | jq -Rs . 2>/dev/null || echo '[]')
        anti_patterns=$(echo "$anti_patterns" | jq --argjson files "$large_files_json" '. + [{"type": "God Object", "files": $files}]' 2>/dev/null || echo '["God Object"]')
        log "Found: God Object anti-pattern"
    fi

    # Spaghetti code (deep nesting)
    local deep_nesting=$(find "$target_dir" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) 2>/dev/null | \
        xargs grep -n "        " 2>/dev/null | head -5 || true)

    if [[ -n "$deep_nesting" ]]; then
        anti_patterns=$(echo "$anti_patterns" | jq '. + ["Deep Nesting"]' 2>/dev/null || echo '["Deep Nesting"]')
        log "Found: Deep Nesting anti-pattern"
    fi

    # Magic numbers
    local magic_numbers=$(find "$target_dir" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) 2>/dev/null | \
        xargs grep -nE '\b[0-9]{3,}\b' 2>/dev/null | head -5 || true)

    if [[ -n "$magic_numbers" ]]; then
        anti_patterns=$(echo "$anti_patterns" | jq '. + ["Magic Numbers"]' 2>/dev/null || echo '["Magic Numbers"]')
        log "Found: Magic Numbers anti-pattern"
    fi

    # Duplicate code
    local duplicate_files=$(find "$target_dir" -type f \( -name "*.ts" -o -name "*.js" -o -name "*.py" \) 2>/dev/null | \
        head -10 | while read -r f; do
            local hash=$(md5sum "$f" 2>/dev/null | cut -d "'" -f1 || echo "")
            echo "$hash $f"
        done | sort | uniq -d -w32 | cut -d "'" -f2- || true)

    if [[ -n "$duplicate_files" ]]; then
        anti_patterns=$(echo "$anti_patterns" | jq '. + ["Duplicate Code"]' 2>/dev/null || echo '["Duplicate Code"]')
        log "Found: Duplicate Code anti-pattern"
    fi

    echo "$anti_patterns"
}

analyze_architecture() {
    local target_dir="${1:-.}"
    log "Analyzing architecture in: $target_dir"

    local layers="[]"
    local components="[]"

    # Detect layered architecture
    if [[ -d "$target_dir/controllers" ]] || [[ -d "$target_dir/routes" ]]; then
        layers=$(echo "$layers" | jq '. + ["Presentation/API"]' 2>/dev/null || echo '["Presentation/API"]')
        log "Found: Presentation/API layer"
    fi

    if [[ -d "$target_dir/services" ]] || [[ -d "$target_dir/business" ]]; then
        layers=$(echo "$layers" | jq '. + ["Business Logic"]' 2>/dev/null || echo '["Business Logic"]')
        log "Found: Business Logic layer"
    fi

    if [[ -d "$target_dir/repositories" ]] || [[ -d "$target_dir/data" ]] || [[ -d "$target_dir/models" ]]; then
        layers=$(echo "$layers" | jq '. + ["Data Access"]' 2>/dev/null || echo '["Data Access"]')
        log "Found: Data Access layer"
    fi

    if [[ -d "$target_dir/utils" ]] || [[ -d "$target_dir/helpers" ]]; then
        layers=$(echo "$layers" | jq '. + ["Utilities"]' 2>/dev/null || echo '["Utilities"]')
        log "Found: Utilities layer"
    fi

    # Detect components
    local component_dirs=$(find "$target_dir" -maxdepth 2 -type d \( -name "*component*" -o -name "*widget*" -o -name "*module*" \) 2>/dev/null || true)
    if [[ -n "$component_dirs" ]]; then
        while IFS= read -r dir; do
            components=$(echo "$components" | jq '. + ["'"$(basename "$dir")"'"]' 2>/dev/null || echo '["component"]')
        done <<< "$component_dirs"
    fi

    jq -n \
        --argjson layers "$layers" \
        --argjson components "$components" \
        '{
            architecture: "Layered",
            layers: $layers,
            components: $components
        }'
}

analyze_dependencies() {
    local target_dir="${1:-.}"
    log "Analyzing dependencies in: $target_dir"

    local dependencies="[]"
    local external_deps="[]"

    # TypeScript/JavaScript dependencies
    if [[ -f "$target_dir/package.json" ]]; then
        dependencies=$(jq -r '.dependencies | keys | .[]' "$target_dir/package.json" 2>/dev/null || echo "")
        external_deps=$(jq -r '.dependencies | keys | .[]' "$target_dir/package.json" 2>/dev/null || echo "")
    fi

    # Python dependencies
    if [[ -f "$target_dir/requirements.txt" ]]; then
        external_deps=$(grep -vE '^#|^$' "$target_dir/requirements.txt" | awk '{print $1}' | head -20 || true)
    fi

    # Go dependencies
    if [[ -f "$target_dir/go.mod" ]]; then
        external_deps=$(grep -E '^require' "$target_dir/go.mod" | awk '{print $2}' | head -20 || true)
    fi

    jq -n \
        --argjson external_deps "$(echo "$external_deps" | jq -Rs 'split("\n") | map(select(length > 0))' 2>/dev/null || echo '[]')" \
        '{
            externalDependencies: $external_deps,
            dependencyCount: ($external_deps | length)
        }'
}

# ============================================================================
# Main Analysis
# ============================================================================

analyze() {
    local target_dir="${1:-.}"
    local output_format="${2:-json}"

    log "Starting reverse engineering analysis of: $target_dir"

    local design_patterns
    local anti_patterns
    local architecture
    local dependencies

    design_patterns=$(detect_design_patterns "$target_dir")
    anti_patterns=$(detect_anti_patterns "$target_dir")
    architecture=$(analyze_architecture "$target_dir")
    dependencies=$(analyze_dependencies "$target_dir")

    local timestamp=$(date -u +%Y-%m-%dT%H:%M:%SZ)

    if command -v jq &>/dev/null; then
        local analysis_json
        analysis_json=$(jq -n \
            --arg timestamp "$timestamp" \
            --arg target_dir "$(cd "$target_dir" && pwd)" \
            --argjson design_patterns "$design_patterns" \
            --argjson anti_patterns "$anti_patterns" \
            --argjson architecture "$architecture" \
            --argjson dependencies "$dependencies" \
            '{
                timestamp: $timestamp,
                targetDirectory: $target_dir,
                designPatterns: $design_patterns,
                antiPatterns: $anti_patterns,
                architecture: $architecture,
                dependencies: $dependencies
            }')

        # Save analysis to file
        local output_file="${OUTPUT_DIR}/analysis-$(date +%s).json"
        echo "$analysis_json" > "$output_file"
        log "Analysis saved to: $output_file"

        if [[ "$output_format" == "markdown" ]]; then
            # Convert to markdown
            echo "# Reverse Engineering Analysis"
            echo ""
            echo "**Generated**: $timestamp"
            echo "**Target**: $target_dir"
            echo ""
            echo "## Design Patterns"
            echo "$design_patterns" | jq -r '.[] | "- " + .' 2>/dev/null || echo "None found"
            echo ""
            echo "## Anti-Patterns"
            echo "$anti_patterns" | jq -r '.[] | "- " + (.type // .)' 2>/dev/null || echo "None found"
            echo ""
            echo "## Architecture"
            echo "**Type**: Layered"
            echo "**Layers**:"
            echo "$architecture" | jq -r '.layers[] | "  - " + .' 2>/dev/null || echo "  - Unknown"
            echo ""
            echo "## Dependencies"
            echo "**External**: $(echo "$dependencies" | jq -r '.dependencyCount // 0' 2>/dev/null || echo "0") packages"
            echo "$dependencies" | jq -r '.externalDependencies[] | "  - " + .' 2>/dev/null || echo "  - None"
        else
            echo "$analysis_json"
        fi
    else
        log "jq not available, using simple output"
        echo "Reverse Engineering Analysis"
        echo "========================="
        echo "Target: $target_dir"
        echo "Timestamp: $timestamp"
        echo ""
        echo "Design Patterns Found:"
        echo "$design_patterns"
        echo ""
        echo "Anti-Patterns Found:"
        echo "$anti_patterns"
    fi
}

# ============================================================================
# CLI Interface
# ============================================================================

case "${1:-help}" in
    analyze)
        analyze "${2:-.}" "${3:-json}"
        ;;

    patterns)
        detect_design_patterns "${2:-.}"
        ;;

    anti-patterns)
        detect_anti_patterns "${2:-.}"
        ;;

    architecture)
        analyze_architecture "${2:-.}"
        ;;

    dependencies)
        analyze_dependencies "${2:-.}"
        ;;

    help|*)
        cat <<EOF
Reverse Engineering Analyzer - Analyze code patterns

Usage: $0 <command> [args]

Commands:
  analyze <dir> [format]  - Full analysis (json or markdown)
  patterns <dir>          - Detect design patterns
  anti-patterns <dir>      - Detect anti-patterns
  architecture <dir>        - Analyze architecture
  dependencies <dir>        - Analyze dependencies

Examples:
  $0 analyze ./src
  $0 analyze ./src markdown
  $0 patterns ./src

Output:
  - JSON format (default): Structured analysis data
  - Markdown format: Human-readable report
  - Saved to: ~/.claude/reverse-engineering/analysis-*.json

Patterns Detected:
  - Singleton, Factory, Observer, Strategy
  - Builder, Repository, Middleware

Anti-Patterns Detected:
  - God Object (files > 500 lines)
  - Deep Nesting (> 4 levels)
  - Magic Numbers (unexplained constants)
  - Duplicate Code (identical files)
EOF
        ;;
esac
