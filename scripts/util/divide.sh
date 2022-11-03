#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

help () {
    error_code=$?
    echo "
No help message yet
"
    exit $error_code
}

divide () {
	cat "$1" | grep -i "$2" > "$1".first
	cat "$1" | grep -iv "$2" > "$1".second
}

divide "$@" || help
trackusage.sh "$0"
