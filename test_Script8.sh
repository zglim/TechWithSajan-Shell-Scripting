#!/bin/bash
# Regression tests for Script8.sh
SCRIPT="$(dirname "$0")/Script8.sh"
PASS=0
FAIL=0

assert_contains() {
    local desc="$1" output="$2" expected="$3"
    if echo "$output" | grep -qF "$expected"; then
        echo "  PASS: $desc"
        (( PASS++ ))
    else
        echo "  FAIL: $desc"
        echo "    expected to contain: $expected"
        echo "    got: $output"
        (( FAIL++ ))
    fi
}

assert_exit() {
    local desc="$1" actual="$2" expected="$3"
    if [ "$actual" -eq "$expected" ]; then
        echo "  PASS: $desc"
        (( PASS++ ))
    else
        echo "  FAIL: $desc (exit $actual, expected $expected)"
        (( FAIL++ ))
    fi
}

echo "=== Test 1: Default values (no args) ==="
out=$(bash "$SCRIPT" 2>&1)
rc=$?
assert_exit "exits 0" "$rc" 0
assert_contains "addition" "$out" "a + b : 30"
assert_contains "subtraction" "$out" "a - b : -10"
assert_contains "multiplication" "$out" "a * b : 200"
assert_contains "division b/a" "$out" "b / a : 2"
assert_contains "modulo b%a" "$out" "b % a : 0"
assert_contains "comparison branch" "$out" "a is less than b"

echo "=== Test 2: a > b path ==="
out=$(bash "$SCRIPT" 30 5 2>&1)
rc=$?
assert_exit "exits 0" "$rc" 0
assert_contains "addition" "$out" "a + b : 35"
assert_contains "comparison branch" "$out" "a is greater than b"
assert_contains "a / b" "$out" "a / b : 6"

echo "=== Test 3: a < b path ==="
out=$(bash "$SCRIPT" 3 17 2>&1)
rc=$?
assert_exit "exits 0" "$rc" 0
assert_contains "comparison branch" "$out" "a is less than b"

echo "=== Test 4: a == b path ==="
out=$(bash "$SCRIPT" 7 7 2>&1)
rc=$?
assert_exit "exits 0" "$rc" 0
assert_contains "comparison branch" "$out" "a is equal to b"

echo "=== Test 5: Division by zero (b=0) ==="
out=$(bash "$SCRIPT" 10 0 2>&1)
rc=$?
assert_exit "exits 0" "$rc" 0
assert_contains "div-by-zero a/b" "$out" "a / b : error (division by zero)"
assert_contains "mod-by-zero a%b" "$out" "a % b : error (division by zero)"

echo "=== Test 6: Division by zero (a=0) ==="
out=$(bash "$SCRIPT" 0 5 2>&1)
rc=$?
assert_exit "exits 0" "$rc" 0
assert_contains "div-by-zero b/a" "$out" "b / a : error (division by zero)"

echo "=== Test 7: Non-integer input ==="
out=$(bash "$SCRIPT" abc 5 2>&1)
rc=$?
assert_exit "exits 1" "$rc" 1
assert_contains "error message" "$out" "not a valid integer"

echo "=== Test 8: Float input rejected ==="
out=$(bash "$SCRIPT" 3.14 2 2>&1)
rc=$?
assert_exit "exits 1" "$rc" 1
assert_contains "error message" "$out" "not a valid integer"

echo "=== Test 9: Missing one argument ==="
out=$(bash "$SCRIPT" 5 2>&1)
rc=$?
assert_exit "exits 1" "$rc" 1
assert_contains "usage hint" "$out" "Usage:"

echo "=== Test 10: Negative numbers ==="
out=$(bash "$SCRIPT" -3 4 2>&1)
rc=$?
assert_exit "exits 0" "$rc" 0
assert_contains "addition" "$out" "a + b : 1"
assert_contains "comparison branch" "$out" "a is less than b"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
