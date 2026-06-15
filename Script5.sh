#!/usr/bin/env bash
# Demonstrate Bash readonly variables:
#   - Define a variable and mark it readonly
#   - Show that reassignment is rejected
#   - Confirm the original value is preserved

set -euo pipefail

# 1. Define and lock the variable
NAME="Tech-Data"
readonly NAME

echo "Original value : NAME=${NAME}"
echo "Readonly status : $(readonly -p | grep -w NAME)"

# 2. Attempt reassignment inside a subshell (which inherits the
#    readonly attribute).  The subshell fails; the parent survives.
if reassign_error=$( (NAME=DEVOPS) 2>&1 ); then
    echo "Subshell did not error, but parent variable is unchanged."
else
    echo "Reassignment blocked — shell said: ${reassign_error:-<no message>}"
fi

# 3. Confirm the value was never modified
if [ "$NAME" = "Tech-Data" ]; then
    echo "Verification   : NAME is still '${NAME}' — readonly protection works."
else
    echo "ERROR: NAME was unexpectedly changed to '${NAME}'." >&2
    exit 1
fi

exit 0
