#!/bin/bash
# Demonstrate basic arithmetic and if/elif comparison for two integers.
# Usage: ./Script8.sh [a] [b]
#   If no arguments are given, defaults to a=10 b=20.

# --- Input handling ---
if [ $# -eq 0 ]; then
    a=10
    b=20
elif [ $# -eq 2 ]; then
    a="$1"
    b="$2"
else
    echo "Error: expected 0 or 2 arguments, got $#" >&2
    echo "Usage: $0 [a] [b]" >&2
    exit 1
fi

# Validate that both inputs are integers (optional leading minus sign)
re='^-?[0-9]+$'
if ! [[ "$a" =~ $re ]]; then
    echo "Error: '$a' is not a valid integer" >&2
    exit 1
fi
if ! [[ "$b" =~ $re ]]; then
    echo "Error: '$b' is not a valid integer" >&2
    exit 1
fi

# --- Arithmetic ---
echo "a = $a, b = $b"
echo "---"
echo "a + b : $(( a + b ))"
echo "a - b : $(( a - b ))"
echo "a * b : $(( a * b ))"

if [ "$b" -eq 0 ]; then
    echo "a / b : error (division by zero)"
    echo "a % b : error (division by zero)"
else
    echo "a / b : $(( a / b ))"
    echo "a % b : $(( a % b ))"
fi

if [ "$a" -eq 0 ]; then
    echo "b / a : error (division by zero)"
    echo "b % a : error (division by zero)"
else
    echo "b / a : $(( b / a ))"
    echo "b % a : $(( b % a ))"
fi

# --- Comparison ---
echo "---"
if [ "$a" -eq "$b" ]; then
    echo "a is equal to b"
elif [ "$a" -gt "$b" ]; then
    echo "a is greater than b"
else
    echo "a is less than b"
fi
