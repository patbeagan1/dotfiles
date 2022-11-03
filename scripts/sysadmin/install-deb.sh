#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

help () {
    error_code=$?
    echo "
No help message yet
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

install () {
	sudo dpkg -i "$1"
}

install "$@" || help
trackusage.sh "$0"
