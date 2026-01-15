#!/bin/bash
# =============================================================================
# TEST SUITE: Bulletproof Debug Verification (Intense Edge Cases)
# Purpose: Stress-test 'extract_error_signature' and 'expand_search_horizons'
#          against complex, messy, and hostile inputs.
# =============================================================================

source ~/.claude/hooks/debug-orchestrator.sh
set +e
set +o pipefail

# Mock Environment Setup
mkdir -p ./bulletproof_mock/src
# Create a dummy minified file
echo "function a(b){throw new Error('x')}" > ./bulletproof_mock/src/bundle.min.js

LOG_FILE="bulletproof_results.log"
rm -f "$LOG_FILE"

log_test() { echo -e "\n\033[0;34m[TEST]\033[0m $1" | tee -a "$LOG_FILE"; }
pass() { echo -e "\033[0;32m[PASS]\033[0m $1" | tee -a "$LOG_FILE"; }
fail() { echo -e "\033[0;31m[FAIL]\033[0m $1" | tee -a "$LOG_FILE"; }

# =============================================================================
# 1. POLYGLOT STACK TRACES
# =============================================================================
log_test "1. Polyglot Stack Traces (Python, Java, Go)"

# Python Traceback
python_err="Traceback (most recent call last):
  File \"/usr/src/app/main.py\", line 42, in <module>
    run_main()
ValueError: invalid literal for int() with base 10: 'xyz'"

raw_py=$(extract_error_signature "$python_err")
echo "RAW_PY_OUTPUT: $raw_py" >> "$LOG_FILE"

json_py=$(echo "$raw_py" | grep "^{" | jq '.')
extracted_py=$(echo "$json_py" | jq -r '.extracted_error')
file_py=$(echo "$json_py" | jq -r '.file_location')

# Matches "ValueError: invalid literal..." ?
if [[ "$extracted_py" == *"ValueError"* ]]; then pass "Python ValueError detected"; else fail "Missed Python Error: $extracted_py"; fi

# Java Stack Trace
java_err="Exception in thread \"main\" java.lang.NullPointerException
	at com.example.myproject.Book.getTitle(Book.java:16)
	at com.example.myproject.Author.getBookTitles(Author.java:25)"

json_java=$(extract_error_signature "$java_err" | grep "^{" | jq '.')
extracted_java=$(echo "$json_java" | jq -r '.extracted_error')
# Note: current regex might fail on "java.lang.NullPointerException" if not prefixed with "Error" etc, 
# but it searches for "Exception". 

if [[ "$extracted_java" == *"NullPointerException"* ]]; then pass "Java Exception detected"; else fail "Missed Java NPE: $extracted_java"; fi


# =============================================================================
# 2. MINIFIED & OBFUSCATED CODE
# =============================================================================
log_test "2. Minified/Obfuscated Code"

min_err="Uncaught Error: x in ./bulletproof_mock/src/bundle.min.js:1:24"
json_min=$(extract_error_signature "$min_err" | grep "^{" | jq '.')
file_min=$(echo "$json_min" | jq -r '.file_location')

if [[ "$file_min" == *"bundle.min.js:1"* ]]; then pass "Minified file path detected"; else fail "Missed minified path: $file_min"; fi


# =============================================================================
# 3. NOISE & CONCURRENCY
# =============================================================================
log_test "3. Noisy Logs (Interleaved Messages)"

noisy_log="[INFO] Starting server
[DEBUG] User connected
[User undefined] Error: Connection Reset
[WARN] Retrying connection
[INFO] Shutting down"

json_noise=$(extract_error_signature "$noisy_log" | grep "^{" | jq '.')
err_noise=$(echo "$json_noise" | jq -r '.extracted_error')

if [[ "$err_noise" == *"Connection Reset"* ]]; then pass "Extracted error from noise"; else fail "Lost in noise: $err_noise"; fi


# =============================================================================
# 4. MALICIOUS / WEIRD INPUTS
# =============================================================================
log_test "4. Malicious Strings / Weird Inputs"

# SQL Injection style string in error
sql_err="Error: SQL syntax error near '' OR '1'='1' -- '"
json_sql=$(extract_error_signature "$sql_err" | grep "^{" | jq '.')
err_sql=$(echo "$json_sql" | jq -r '.extracted_error')

if [[ "$err_sql" == *"SQL syntax error"* ]]; then pass "Handled SQL-like error string"; else fail "Choked on SQL chars: $err_sql"; fi

# Empty Input
json_empty=$(extract_error_signature "" | grep "^{" | jq '.')
has_sig=$(echo "$json_empty" | jq -r '.has_signature')

if [[ "$has_sig" == "false" ]]; then pass "Correctly handled empty input"; else fail "Failed empty check"; fi


# =============================================================================
# 5. CONTEXT AWARENESS (App Specifics)
# =============================================================================
log_test "5. Context Awareness: 'unknown' context"

# Should fallback cleanly
res=$(expand_search_horizons "Something broke" "unknown" | grep "^{" | jq '.')
query=$(echo "$res" | jq -r '.deep_search_results.web_search_recommendation.query')

if [[ "$query" == *"Something broke"* ]]; then pass "Handled 'unknown' context gracefully"; else fail "Context issue: $query"; fi

# Cleanup
rm -rf ./bulletproof_mock
echo "Tests Done."
