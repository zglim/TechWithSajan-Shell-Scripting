#!/bin/sh
# Script16.sh - Reusable counting tool based on while loop
# Usage: ./Script16.sh [-s start] [-e end] [-i step] [-p prefix] [-l]
#   -s start   : starting value (default: 0)
#   -e end     : ending value, exclusive (default: 10)
#   -i step    : increment step (default: 1)
#   -p prefix  : optional prefix string for each line
#   -l         : label mode, show step number before each value
#
# Examples:
#   ./Script16.sh                    # counts 0..9
#   ./Script16.sh -s 1 -e 5         # counts 1..4
#   ./Script16.sh -s 10 -e 0 -i -2  # counts 10,8,6,4,2
#   ./Script16.sh -s 0 -e 5 -l      # with step labels
#   ./Script16.sh -p "val: "        # with prefix

# Defaults
START=0
END=10
STEP=1
PREFIX=""
LABEL=0

# Parse arguments
while getopts "s:e:i:p:lh" opt; do
  case "$opt" in
    s) START="$OPTARG" ;;
    e) END="$OPTARG" ;;
    i) STEP="$OPTARG" ;;
    p) PREFIX="$OPTARG" ;;
    l) LABEL=1 ;;
    h)
      sed -n '2,14p' "$0" | sed 's/^# *//'
      exit 0
      ;;
    *)
      echo "Error: Unknown option. Use -h for help." >&2
      exit 1
      ;;
  esac
done

# --- Input validation ---

# Check if a value is a valid integer (allows negative)
is_integer() {
  case "$1" in
    ''|*[!0-9-]*) return 1 ;;
    *-*-*) return 1 ;;  # more than one dash
  esac
  # Allow leading minus only
  case "$1" in
    -) return 1 ;;  # just a dash
    -*[!0-9]*) return 1 ;;
  esac
  return 0
}

if ! is_integer "$START"; then
  echo "Error: start value '$START' is not a valid integer." >&2
  exit 1
fi

if ! is_integer "$END"; then
  echo "Error: end value '$END' is not a valid integer." >&2
  exit 1
fi

if ! is_integer "$STEP"; then
  echo "Error: step value '$STEP' is not a valid integer." >&2
  exit 1
fi

if [ "$STEP" -eq 0 ]; then
  echo "Error: step cannot be zero." >&2
  exit 1
fi

# Check direction consistency
if [ "$STEP" -gt 0 ] && [ "$START" -gt "$END" ]; then
  echo "Error: positive step ($STEP) but start ($START) > end ($END). Use a negative step." >&2
  exit 1
fi

if [ "$STEP" -lt 0 ] && [ "$START" -lt "$END" ]; then
  echo "Error: negative step ($STEP) but start ($START) < end ($END). Use a positive step." >&2
  exit 1
fi

# --- Counting loop ---
a=$START
count=1

while true; do
  # Check termination condition based on direction
  if [ "$STEP" -gt 0 ]; then
    [ "$a" -ge "$END" ] && break
  else
    [ "$a" -le "$END" ] && break
  fi

  # Build output line
  line=""
  if [ "$LABEL" -eq 1 ]; then
    line="[step ${count}] "
  fi
  line="${line}${PREFIX}${a}"

  echo "$line"

  a=$(expr $a + $STEP)
  count=$(expr $count + 1)
done
