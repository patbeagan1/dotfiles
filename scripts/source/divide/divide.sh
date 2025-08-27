#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

scriptname="$(basename "$0")"

help () {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <file> <pattern>

Divides a file into two parts based on a pattern match.
Creates two new files: <file>.first (matching lines) and <file>.second (non-matching lines).

Arguments:
  file      Input file to divide
  pattern   Pattern to match (case-insensitive)

Examples:
  $scriptname data.txt error          # Creates data.txt.first and data.txt.second
  $scriptname log.txt WARNING         # Separates warning and non-warning lines
"
    exit $error_code
}

divide () {
	cat "$1" | grep -i "$2" > "$1".first
	cat "$1" | grep -iv "$2" > "$1".second
}

divide "$@" || help
trackusage.sh "$0"
