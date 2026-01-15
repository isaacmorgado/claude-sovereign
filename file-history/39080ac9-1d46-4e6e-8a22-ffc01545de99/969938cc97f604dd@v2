#!/bin/bash
# Retry Command with Backoff - Wraps any command with smart retry logic
# Usage: retry-command.sh [max_retries] [command...]
# Example: retry-command.sh 3 npm test

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ERROR_HANDLER="$SCRIPT_DIR/error-handler.sh"
LOG_FILE="${HOME}/.claude/retry-command.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Parse arguments
MAX_RETRIES="${1:-3}"
shift
COMMAND=("$@")

if [[ ${#COMMAND[@]} -eq 0 ]]; then
    echo "Usage: retry-command.sh [max_retries] [command...]"
    exit 1
fi

ATTEMPT=0
LAST_ERROR=""

while [[ $ATTEMPT -lt $MAX_RETRIES ]]; do
    log "Attempt $((ATTEMPT + 1))/$MAX_RETRIES: ${COMMAND[*]}"

    # Run command and capture output
    set +e
    OUTPUT=$("${COMMAND[@]}" 2>&1)
    EXIT_CODE=$?
    set -e

    if [[ $EXIT_CODE -eq 0 ]]; then
        echo "$OUTPUT"
        log "Success on attempt $((ATTEMPT + 1))"
        exit 0
    fi

    LAST_ERROR="$OUTPUT"
    log "Failed with exit code $EXIT_CODE"

    # Use error handler to classify and determine retry
    if [[ -x "$ERROR_HANDLER" ]]; then
        HANDLER_OUTPUT=$("$ERROR_HANDLER" "$LAST_ERROR" "$ATTEMPT" "$MAX_RETRIES" "${COMMAND[*]}")

        SHOULD_RETRY=$(echo "$HANDLER_OUTPUT" | jq -r '.shouldRetry')
        BACKOFF_MS=$(echo "$HANDLER_OUTPUT" | jq -r '.backoffMs')
        CLASSIFICATION=$(echo "$HANDLER_OUTPUT" | jq -r '.classification')

        log "Classification: $CLASSIFICATION, Retry: $SHOULD_RETRY, Backoff: ${BACKOFF_MS}ms"

        if [[ "$SHOULD_RETRY" != "true" ]]; then
            echo "Error not retryable ($CLASSIFICATION):"
            echo "$LAST_ERROR"
            exit $EXIT_CODE
        fi

        # Wait with backoff
        BACKOFF_SEC=$((BACKOFF_MS / 1000))
        if [[ $BACKOFF_SEC -gt 0 ]]; then
            log "Waiting ${BACKOFF_SEC}s before retry..."
            sleep $BACKOFF_SEC
        fi
    else
        # Fallback: simple retry with fixed delay
        sleep $((2 ** ATTEMPT))
    fi

    ATTEMPT=$((ATTEMPT + 1))
done

# All retries exhausted
echo "All $MAX_RETRIES attempts failed:"
echo "$LAST_ERROR"
log "All retries exhausted for: ${COMMAND[*]}"
exit 1
