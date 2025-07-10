#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

scriptname="$(basename "$0")"

help () {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <max_number>

Generates a random number between 1 and the specified maximum value.

Arguments:
  max_number    Maximum value for the random number (inclusive)

Examples:
  $scriptname 10         # Random number between 1 and 10
  $scriptname 100        # Random number between 1 and 100
  $scriptname 6          # Simulates a die roll (1-6)
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

random () {
	if [ ! $# -eq 1 ]
	then
		echo "Requires int arg"
		return 1
	fi
	echo $((1 + RANDOM % $1))
}

random "$@" || help
trackusage.sh "$0"
