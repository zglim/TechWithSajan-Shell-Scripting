#!/usr/bin/env bash
# Script18.sh — Task orchestration demo
# Function one prepares/validates context, function two executes the action.
# Usage: ./Script18.sh <task_name> [username]

set -euo pipefail

# ── Globals for tracking execution steps ──
STEPS_LOG=()

log_step() {
  STEPS_LOG+=("$1")
}

# ── Function one: prepare and validate input ──
# Validates parameters and exports normalised values for function two.
prepare_context() {
  local task_name="${1:-}"
  local username="${2:-anonymous}"

  log_step "prepare_context: validating input"

  # --- error handling: missing required parameter ---
  if [[ -z "$task_name" ]]; then
    echo "ERROR: task_name is required." >&2
    echo "Usage: $0 <task_name> [username]" >&2
    return 1
  fi

  # --- error handling: empty / whitespace-only input ---
  if [[ "$task_name" =~ ^[[:space:]]*$ ]]; then
    echo "ERROR: task_name must not be empty or whitespace." >&2
    return 1
  fi

  # --- error handling: illegal characters (allow alphanumeric, dash, underscore) ---
  if [[ ! "$task_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "ERROR: task_name contains illegal characters. Only [a-zA-Z0-9_-] are allowed." >&2
    return 1
  fi

  if [[ ! "$username" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "ERROR: username contains illegal characters. Only [a-zA-Z0-9_-] are allowed." >&2
    return 1
  fi

  # Export normalised values for the next function
  PREPARED_TASK="$task_name"
  PREPARED_USER="$username"

  log_step "prepare_context: task='$task_name', user='$username'"
}

# ── Function two: execute the actual task ──
execute_task() {
  local task="$PREPARED_TASK"
  local user="$PREPARED_USER"

  log_step "execute_task: running task '$task' for user '$user'"

  RESULT="Task '$task' executed successfully by user '$user'."
  echo "$RESULT"

  log_step "execute_task: completed"
}

# ── Summary: print a unified execution report ──
print_summary() {
  echo ""
  echo "========== Execution Summary =========="
  echo "Input received  : task='$PREPARED_TASK', user='$PREPARED_USER'"
  echo "Steps executed  :"
  for i in "${!STEPS_LOG[@]}"; do
    echo "  $((i + 1)). ${STEPS_LOG[$i]}"
  done
  echo "Final result    : $RESULT"
  echo "======================================="
}

# ── Main entry point ──
main() {
  # prepare_context validates and sets PREPARED_TASK / PREPARED_USER
  prepare_context "$@" || return $?

  # execute_task uses the prepared values
  execute_task

  # Print unified summary
  print_summary
}

main "$@"
