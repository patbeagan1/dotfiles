#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

help() {
    error_code=$?
    echo "
    Opens a browser to the specified content.
    "
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

q() {
    content="$(echo $* | sed "s/\n/%20/g" | sed 's/ /%20/g')" 
    echo "$content"

    if isMac.sh; then
        open -a Safari "$content"
    else
        firefox "$content"
    fi
}

q "$@" || help
trackusage.sh "$0"
