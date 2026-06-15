#!/usr/bin/env bash
# Regression tests for Script18.sh
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT="${SCRIPT_DIR}/Script18.sh"
PASS=0
FAIL=0

assert() {
    local desc="$1"
    local expected_exit="$2"
    shift 2
    local output
    output=$("$@" 2>&1) || true

    # Re-run to capture actual exit code
    "$@" >/dev/null 2>&1
    local actual_exit=$?

    local ok=true

    if [[ "$actual_exit" -ne "$expected_exit" ]]; then
        echo "FAIL [$desc]: expected exit=$expected_exit, got exit=$actual_exit"
        ok=false
    fi

    if [[ "$ok" == true ]]; then
        echo "PASS [$desc]"
        ((PASS++))
    else
        ((FAIL++))
    fi
    # Return output for further checks
    echo "$output"
}

echo "===== Running Script18.sh regression tests ====="
echo ""

# ── Test 1: Normal input with known task (greet) ──
echo "-- Test 1: Normal input 'greet alice' --"
output=$(bash "$SCRIPT" greet alice 2>&1)
exit_code=$?
if [[ $exit_code -eq 0 ]]; then
    echo "PASS [normal input exits 0]"; ((PASS++))
else
    echo "FAIL [normal input exits 0]: got exit=$exit_code"; ((FAIL++))
fi

# Check summary contains input
if echo "$output" | grep -q "Input task  : greet"; then
    echo "PASS [summary shows task name]"; ((PASS++))
else
    echo "FAIL [summary shows task name]"; ((FAIL++))
fi
if echo "$output" | grep -q "Input user  : alice"; then
    echo "PASS [summary shows username]"; ((PASS++))
else
    echo "FAIL [summary shows username]"; ((FAIL++))
fi

# Check function call order in steps
if echo "$output" | grep -q "prepare_context:.*received"; then
    echo "PASS [summary shows prepare_context step]"; ((PASS++))
else
    echo "FAIL [summary shows prepare_context step]"; ((FAIL++))
fi
if echo "$output" | grep -q "execute_task:.*started"; then
    echo "PASS [summary shows execute_task step]"; ((PASS++))
else
    echo "FAIL [summary shows execute_task step]"; ((FAIL++))
fi

# Check final result appears
if echo "$output" | grep -q "Result.*Hello, alice"; then
    echo "PASS [summary shows final result]"; ((PASS++))
else
    echo "FAIL [summary shows final result]"; ((FAIL++))
fi
if echo "$output" | grep -q "Status.*success"; then
    echo "PASS [summary shows success status]"; ((PASS++))
else
    echo "FAIL [summary shows success status]"; ((FAIL++))
fi

echo ""

# ── Test 2: Different task produces different output ──
echo "-- Test 2: Different task 'report bob' --"
output2=$(bash "$SCRIPT" report bob 2>&1)
if echo "$output2" | grep -q "Report generated for bob"; then
    echo "PASS [different task gives different result]"; ((PASS++))
else
    echo "FAIL [different task gives different result]"; ((FAIL++))
fi

echo ""

# ── Test 3: Missing required parameter ──
echo "-- Test 3: Missing parameter --"
output3=$(bash "$SCRIPT" 2>&1)
exit_code3=$?
if [[ $exit_code3 -ne 0 ]]; then
    echo "PASS [missing param exits non-zero]"; ((PASS++))
else
    echo "FAIL [missing param exits non-zero]: got exit=$exit_code3"; ((FAIL++))
fi
if echo "$output3" | grep -qi "error.*missing"; then
    echo "PASS [missing param shows error message]"; ((PASS++))
else
    echo "FAIL [missing param shows error message]"; ((FAIL++))
fi

echo ""

# ── Test 4: Illegal characters in task name ──
echo "-- Test 4: Illegal task name --"
output4=$(bash "$SCRIPT" "hello world!" 2>&1)
exit_code4=$?
if [[ $exit_code4 -ne 0 ]]; then
    echo "PASS [illegal task name exits non-zero]"; ((PASS++))
else
    echo "FAIL [illegal task name exits non-zero]: got exit=$exit_code4"; ((FAIL++))
fi
if echo "$output4" | grep -qi "illegal"; then
    echo "PASS [illegal task name shows error about illegal chars]"; ((PASS++))
else
    echo "FAIL [illegal task name shows error about illegal chars]"; ((FAIL++))
fi

echo ""

# ── Test 5: Illegal characters in username ──
echo "-- Test 5: Illegal username --"
output5=$(bash "$SCRIPT" greet "bad user!" 2>&1)
exit_code5=$?
if [[ $exit_code5 -ne 0 ]]; then
    echo "PASS [illegal username exits non-zero]"; ((PASS++))
else
    echo "FAIL [illegal username exits non-zero]: got exit=$exit_code5"; ((FAIL++))
fi
if echo "$output5" | grep -qi "illegal"; then
    echo "PASS [illegal username shows error about illegal chars]"; ((PASS++))
else
    echo "FAIL [illegal username shows error about illegal chars]"; ((FAIL++))
fi

echo ""

# ── Test 6: Function call order in summary ──
echo "-- Test 6: Function call order in summary --"
# prepare_context must appear before execute_task in the steps
pc_line=$(echo "$output" | grep -n "prepare_context:.*received" | head -1 | cut -d: -f1)
et_line=$(echo "$output" | grep -n "execute_task:.*started" | head -1 | cut -d: -f1)
if [[ -n "$pc_line" && -n "$et_line" && "$pc_line" -lt "$et_line" ]]; then
    echo "PASS [prepare_context runs before execute_task]"; ((PASS++))
else
    echo "FAIL [prepare_context runs before execute_task]"; ((FAIL++))
fi

echo ""
echo "===== Results: $PASS passed, $FAIL failed ====="

if [[ $FAIL -gt 0 ]]; then
    exit 1
fi
exit 0
