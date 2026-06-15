#!/usr/bin/env bash
# test_Script18.sh — Regression tests for Script18.sh

set -e

SCRIPT="./Script18.sh"
PASS=0
FAIL=0

# Helper function to run a test
run_test() {
  local test_name="$1"
  local expected_exit="$2"
  local expected_output="$3"
  shift 3
  local args=("$@")

  echo "────────────────────────────────────────"
  echo "TEST: $test_name"
  echo "Command: $SCRIPT ${args[*]}"

  local actual_output
  local actual_exit=0
  actual_output=$("$SCRIPT" "${args[@]}" 2>&1) || actual_exit=$?

  if [[ "$actual_exit" -eq "$expected_exit" ]]; then
    echo "✓ Exit code correct: $actual_exit"
  else
    echo "✗ Exit code WRONG: expected $expected_exit, got $actual_exit"
    FAIL=$((FAIL + 1))
    return 1
  fi

  if echo "$actual_output" | grep -qF "$expected_output"; then
    echo "✓ Output contains: '$expected_output'"
  else
    echo "✗ Output MISSING expected text: '$expected_output'"
    echo "Actual output:"
    echo "$actual_output"
    FAIL=$((FAIL + 1))
    return 1
  fi

  echo "✓ PASSED"
  PASS=$((PASS + 1))
  echo ""
}

echo "========================================"
echo "Running regression tests for Script18.sh"
echo "========================================"
echo ""

# Test 1: Normal input - complete function chain
run_test "Normal input with task and user" \
  0 \
  "Task 'build_project' executed successfully" \
  "build_project" "alice"

# Test 2: Normal input with only task name (default user)
run_test "Normal input with only task name" \
  0 \
  "user 'anonymous'" \
  "deploy_app"

# Test 3: Missing required parameter (no task name)
run_test "Missing task_name parameter" \
  1 \
  "ERROR: task_name is required"

# Test 4: Empty task name (whitespace only)
run_test "Empty task name (whitespace)" \
  1 \
  "ERROR: task_name must not be empty" \
  "   "

# Test 5: Illegal characters in task name
run_test "Illegal characters in task_name" \
  1 \
  "ERROR: task_name contains illegal characters" \
  "bad@task"

# Test 6: Illegal characters in username
run_test "Illegal characters in username" \
  1 \
  "ERROR: username contains illegal characters" \
  "valid_task" "user@name"

# Test 7: Verify execution summary is present
run_test "Execution summary contains function call order" \
  0 \
  "prepare_context: validating input" \
  "test_task" "bob"

# Test 8: Verify summary shows both function steps
run_test "Summary shows execute_task step" \
  0 \
  "execute_task: running task" \
  "another_task" "charlie"

# Test 9: Verify summary shows final result
run_test "Summary shows final result" \
  0 \
  "Final result" \
  "final_task" "dave"

# Test 10: Special allowed characters (dash and underscore)
run_test "Task name with dash and underscore" \
  0 \
  "Task 'build-test_01' executed successfully" \
  "build-test_01" "user_name"

echo "========================================"
echo "TEST SUMMARY"
echo "========================================"
echo "Passed: $PASS"
echo "Failed: $FAIL"
echo "Total:  $((PASS + FAIL))"
echo "========================================"

if [[ "$FAIL" -eq 0 ]]; then
  echo "✓ All tests passed!"
  exit 0
else
  echo "✗ Some tests failed"
  exit 1
fi
