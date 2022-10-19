#!/usr/bin/env zsh

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
	cat "$1" | grep "$2" > "$1".first
	cat "$1" | grep -v "$2" > "$1".second
}

divide "$@" || help
trackusage.sh "$0"
