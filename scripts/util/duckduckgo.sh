#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

help () {
    error_code=$?
    echo "
No help message yet
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

q () {
	local content=$(echo "$@" | sed 's/ /%20/g')
	open -a Safari https://duckduckgo.com/"$content"
}

q "$@" || help
trackusage.sh "$0"
