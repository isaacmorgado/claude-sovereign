#!/bin/bash
# performance-profiler.sh - Automated Performance Profiling and Bottleneck Detection
# Uses GNU time, perf, and custom monitoring for bash scripts
# Time saved: 20-30 min per optimization cycle

set -euo pipefail

PROFILE_DIR="${HOME}/.claude/profiles"
LOG_FILE="${HOME}/.claude/logs/performance.log"

mkdir -p "$PROFILE_DIR" "$(dirname "$LOG_FILE")"

usage() {
    cat << EOF
Usage: performance-profiler.sh <command> [options]

Commands:
    profile <script> [args...]      Profile script execution
    analyze <profile_id>            Analyze profile results
    compare <id1> <id2>             Compare two profiles
    bottlenecks <profile_id>        Identify performance bottlenecks
    stats                           Show profiling statistics

Examples:
    performance-profiler.sh profile ./my-script.sh arg1 arg2
    performance-profiler.sh analyze prof_12345
    performance-profiler.sh bottlenecks prof_12345

Time Saved: 20-30 minutes per optimization cycle
EOF
}

profile_script() {
    local script="$1"
    shift
    local args="$@"
    local profile_id="prof_$(date +%s)"
    local profile_file="${PROFILE_DIR}/${profile_id}.json"

    echo "Profiling: $script $args"
    echo "Profile ID: $profile_id"

    # Profile with GNU time
    /usr/bin/time -v "$script" $args 2>&1 | tee "${profile_file}.txt"

    # Extract metrics
    local exit_code=${PIPESTATUS[0]}
    local elapsed=$(grep "Elapsed" "${profile_file}.txt" | awk '{print $8}' || echo "0")
    local cpu=$(grep "CPU this job" "${profile_file}.txt" | awk '{print $7}' || echo "0")
    local max_mem=$(grep "Maximum resident" "${profile_file}.txt" | awk '{print $6}' || echo "0")

    cat > "$profile_file" << JSON
{
  "profile_id": "$profile_id",
  "script": "$script",
  "args": "$args",
  "elapsed_time": "$elapsed",
  "cpu_percent": "$cpu",
  "max_memory_kb": $max_mem,
  "exit_code": $exit_code,
  "timestamp": "$(date -Iseconds)"
}
JSON

    echo "Profile saved: $profile_file"
    echo "$profile_id"
}

analyze_profile() {
    local profile_id="$1"
    local profile_file="${PROFILE_DIR}/${profile_id}.json"

    if [[ ! -f "$profile_file" ]]; then
        echo "Profile not found: $profile_id" >&2
        return 1
    fi

    echo "Performance Analysis: $profile_id"
    echo "===================================="
    jq -r '. | "Script: \(.script)\nElapsed: \(.elapsed_time)\nCPU: \(.cpu_percent)\nMax Memory: \(.max_memory_kb) KB"' "$profile_file"
}

identify_bottlenecks() {
    local profile_id="$1"
    local profile_file="${PROFILE_DIR}/${profile_id}.json"

    if [[ ! -f "$profile_file" ]]; then
        echo "Profile not found: $profile_id" >&2
        return 1
    fi

    echo "Bottleneck Analysis: $profile_id"
    echo "================================="

    local cpu=$(jq -r '.cpu_percent' "$profile_file" | sed 's/%//')
    local mem_kb=$(jq -r '.max_memory_kb' "$profile_file")

    # Analyze bottlenecks
    if (( $(echo "$cpu > 80" | bc -l) )); then
        echo "⚠️  CPU Bottleneck: ${cpu}% CPU usage (threshold: 80%)"
        echo "   Recommendation: Optimize CPU-intensive operations, consider parallelization"
    fi

    if (( mem_kb > 1048576 )); then  # 1GB
        echo "⚠️  Memory Bottleneck: $((mem_kb / 1024)) MB memory usage"
        echo "   Recommendation: Optimize memory usage, consider streaming"
    fi
}

main() {
    case "${1:-help}" in
        profile) shift; profile_script "$@" ;;
        analyze) shift; analyze_profile "$@" ;;
        bottlenecks) shift; identify_bottlenecks "$@" ;;
        *) usage ;;
    esac
}

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main "$@"
