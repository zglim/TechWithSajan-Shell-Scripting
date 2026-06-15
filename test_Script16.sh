#!/bin/sh
# test_Script16.sh - Regression tests for Script16.sh
SCRIPT="$(dirname "$0")/Script16.sh"
PASS=0
FAIL=0

assert_eq() {
  test_name="$1"
  expected="$2"
  actual="$3"
  if [ "$expected" = "$actual" ]; then
    echo "PASS: $test_name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $test_name"
    echo "  expected: $(echo "$expected" | head -3)..."
    echo "  actual:   $(echo "$actual" | head -3)..."
    FAIL=$((FAIL + 1))
  fi
}

assert_exit() {
  test_name="$1"
  expected_code="$2"
  shift 2
  "$@" >/dev/null 2>&1
  actual_code=$?
  if [ "$actual_code" -eq "$expected_code" ]; then
    echo "PASS: $test_name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $test_name (expected exit $expected_code, got $actual_code)"
    FAIL=$((FAIL + 1))
  fi
}

assert_stderr_contains() {
  test_name="$1"
  pattern="$2"
  shift 2
  err=$("$@" 2>&1 >/dev/null)
  if echo "$err" | grep -q "$pattern"; then
    echo "PASS: $test_name"
    PASS=$((PASS + 1))
  else
    echo "FAIL: $test_name (stderr did not contain '$pattern')"
    echo "  stderr: $err"
    FAIL=$((FAIL + 1))
  fi
}

echo "=== Script16.sh Regression Tests ==="
echo ""

# Test 1: Default behavior (0 to 9)
expected="0
1
2
3
4
5
6
7
8
9"
actual=$(sh "$SCRIPT")
assert_eq "Default behavior (0..9)" "$expected" "$actual"

# Test 2: Ascending count with custom range
expected="3
4
5
6"
actual=$(sh "$SCRIPT" -s 3 -e 7)
assert_eq "Ascending 3..6" "$expected" "$actual"

# Test 3: Custom step
expected="0
2
4
6
8"
actual=$(sh "$SCRIPT" -s 0 -e 10 -i 2)
assert_eq "Step of 2 (0,2,4,6,8)" "$expected" "$actual"

# Test 4: Descending count
expected="10
8
6
4
2"
actual=$(sh "$SCRIPT" -s 10 -e 0 -i -2)
assert_eq "Descending 10..2 step -2" "$expected" "$actual"

# Test 5: Step zero should error
assert_exit "Step=0 exits non-zero" 1 sh "$SCRIPT" -i 0
assert_stderr_contains "Step=0 error message" "step cannot be zero" sh "$SCRIPT" -i 0

# Test 6: Non-integer input should error
assert_exit "Non-integer start exits non-zero" 1 sh "$SCRIPT" -s abc
assert_stderr_contains "Non-integer start error msg" "not a valid integer" sh "$SCRIPT" -s abc

assert_exit "Non-integer end exits non-zero" 1 sh "$SCRIPT" -e 3.5
assert_stderr_contains "Non-integer end error msg" "not a valid integer" sh "$SCRIPT" -e 3.5

assert_exit "Non-integer step exits non-zero" 1 sh "$SCRIPT" -i foo
assert_stderr_contains "Non-integer step error msg" "not a valid integer" sh "$SCRIPT" -i foo

# Test 7: Direction mismatch
assert_exit "Positive step but start>end exits non-zero" 1 sh "$SCRIPT" -s 10 -e 0 -i 2
assert_stderr_contains "Direction mismatch error (pos step)" "positive step" sh "$SCRIPT" -s 10 -e 0 -i 2

assert_exit "Negative step but start<end exits non-zero" 1 sh "$SCRIPT" -s 0 -e 10 -i -2
assert_stderr_contains "Direction mismatch error (neg step)" "negative step" sh "$SCRIPT" -s 0 -e 10 -i -2

# Test 8: Label mode
expected="[step 1] 0
[step 2] 1
[step 3] 2"
actual=$(sh "$SCRIPT" -s 0 -e 3 -l)
assert_eq "Label mode" "$expected" "$actual"

# Test 9: Prefix mode
expected="num: 5
num: 6
num: 7"
actual=$(sh "$SCRIPT" -s 5 -e 8 -p "num: ")
assert_eq "Prefix mode" "$expected" "$actual"

# Test 10: Label + Prefix combined
expected="[step 1] >> 0
[step 2] >> 1"
actual=$(sh "$SCRIPT" -s 0 -e 2 -l -p ">> ")
assert_eq "Label + Prefix combined" "$expected" "$actual"

# Summary
echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
if [ "$FAIL" -gt 0 ]; then
  exit 1
fi
exit 0
