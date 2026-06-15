#!/usr/bin/env bash
# Task orchestration example: one function prepares context, another executes the task.
# Usage: bash Script18.sh <task_name> [username]

set -euo pipefail

# ── Global state used for the execution summary ──
STEPS_LOG=()
FINAL_STATUS=""
FINAL_RESULT=""

# ── Logging helper ──
log_step() {
    STEPS_LOG+=("$1")
    echo "[step] $1"
}

# ── Function 2: execute the task using prepared context ──
execute_task() {
    local task_name="$1"
    local username="$2"
    local timestamp="$3"

    log_step "execute_task: started task '${task_name}' for user '${username}'"

    # Simulate task execution based on the task name
    case "$task_name" in
        greet)
            FINAL_RESULT="Hello, ${username}! Welcome at ${timestamp}."
            ;;
        report)
            FINAL_RESULT="Report generated for ${username} at ${timestamp}. All systems nominal."
            ;;
        deploy)
            FINAL_RESULT="Deployment initiated by ${username} at ${timestamp}. Status: OK."
            ;;
        *)
            FINAL_RESULT="Task '${task_name}' completed by ${username} at ${timestamp}."
            ;;
    esac

    FINAL_STATUS="success"
    log_step "execute_task: finished with status '${FINAL_STATUS}'"
}

# ── Function 1: prepare / validate context, then call function 2 ──
prepare_context() {
    local task_name="$1"
    local username="${2:-$(whoami)}"

    log_step "prepare_context: received task='${task_name}', user='${username}'"

    # Validate task_name: must be non-empty alphanumeric / underscore / hyphen
    if [[ -z "$task_name" ]]; then
        echo "ERROR: task name cannot be empty." >&2
        return 1
    fi
    if [[ ! "$task_name" =~ ^[a-zA-Z0-9_-]+$ ]]; then
        echo "ERROR: task name '${task_name}' contains illegal characters. Only [a-zA-Z0-9_-] allowed." >&2
        return 1
    fi

    # Validate username
    if [[ -z "$username" ]]; then
        echo "ERROR: username cannot be empty." >&2
        return 1
    fi
    if [[ ! "$username" =~ ^[a-zA-Z0-9_.-]+$ ]]; then
        echo "ERROR: username '${username}' contains illegal characters. Only [a-zA-Z0-9_.-] allowed." >&2
        return 1
    fi

    local timestamp
    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    log_step "prepare_context: validation passed, calling execute_task"

    # Call function 2 with prepared context
    execute_task "$task_name" "$username" "$timestamp"
}

# ── Print unified summary ──
print_summary() {
    local input_task="$1"
    local input_user="$2"

    echo ""
    echo "========== Execution Summary =========="
    echo "Input task  : ${input_task}"
    echo "Input user  : ${input_user}"
    echo "Steps       :"
    for step in "${STEPS_LOG[@]}"; do
        echo "  - ${step}"
    done
    echo "Result      : ${FINAL_RESULT}"
    echo "Status      : ${FINAL_STATUS}"
    echo "========================================"
}

# ── Main entry point ──
main() {
    if [[ $# -lt 1 ]]; then
        echo "ERROR: missing required argument <task_name>." >&2
        echo "Usage: bash Script18.sh <task_name> [username]" >&2
        exit 1
    fi

    local task_name="$1"
    local username="${2:-$(whoami)}"

    # Run the function chain: prepare_context → execute_task
    if prepare_context "$task_name" "$username"; then
        print_summary "$task_name" "$username"
        exit 0
    else
        FINAL_STATUS="failed"
        print_summary "$task_name" "$username"
        exit 1
    fi
}

main "$@"
