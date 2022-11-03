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
