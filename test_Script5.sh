#!/usr/bin/env bash
# Regression tests for Script5.sh — readonly variable demonstration
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="$SCRIPT_DIR/Script5.sh"
PASS=0
FAIL=0

pass() { ((PASS++)); echo "  PASS: $1"; }
fail() { ((FAIL++)); echo "  FAIL: $1" >&2; }

echo "=== Running Script5.sh regression tests ==="

# Capture full output and exit code
output=""
exit_code=0
output=$(bash "$SCRIPT" 2>&1) || exit_code=$?

# 1. Script exits with code 0
if [ "$exit_code" -eq 0 ]; then
    pass "script exits with code 0"
else
    fail "script exited with code $exit_code (expected 0)"
fi

# 2. Variable was successfully set to readonly (output shows readonly status)
if echo "$output" | grep -q 'readonly\|declare -r'; then
    pass "output confirms variable is readonly"
else
    fail "output does not show readonly status"
fi

# 3. Original value is preserved after reassignment attempt
if echo "$output" | grep -q 'NAME.*Tech-Data'; then
    pass "original value 'Tech-Data' is preserved"
else
    fail "original value 'Tech-Data' not found in output"
fi

# 4. Reassignment failure message mentions 'readonly' (not an unrelated error)
if echo "$output" | grep -qi 'readonly.*variable\|reassignment blocked'; then
    pass "failure message indicates readonly restriction"
else
    fail "failure message does not clearly indicate readonly restriction"
fi

# 5. No unhandled error leaks (script should not print to stderr outside captured lines)
stderr_output=""
stderr_output=$(bash "$SCRIPT" 2>&1 1>/dev/null) || true
# Any stderr content should still be part of the controlled demonstration,
# not an unhandled crash.  The script redirects subshell stderr into stdout
# via capture, so direct stderr should be empty on success.
if [ -z "$stderr_output" ]; then
    pass "no unhandled stderr output"
else
    fail "unexpected stderr: $stderr_output"
fi

echo ""
echo "Results: $PASS passed, $FAIL failed"
[ "$FAIL" -eq 0 ]
