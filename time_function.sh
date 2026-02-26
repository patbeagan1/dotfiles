#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

Converts a command or function into a standalone shell script with proper header, 
argument parsing, and help functionality. The script will be saved as <command>.sh 
and made executable.

Examples:
  $scriptname ls          # Creates ls.sh with ls functionality
  $scriptname myfunction  # Creates myfunction.sh with myfunction functionality
"
    exit $error_code
}

main() {

    emulate -L zsh
    zmodload zsh/zutil || return 1

    local help
    zparseopts -D -F -K -- \
        {h,-help}=help ||
        return 1

    if (($#help)); then help; fi

time_function () {
	local action="$1" 
	zmodload zsh/datetime
	start=$EPOCHREALTIME 
	eval "$action"
	end=$EPOCHREALTIME 
	print $(( end - start ))
}

    time_function "$@" || help
}

main "$@" || help
trackusage.sh "$0"
