#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

Checks the git status of all repositories in the current directory.
Shows the status of each git repository with brief output format.

Features:
  - Iterates through all subdirectories
  - Shows current directory path
  - Displays git status in brief format (-sb)
  - Adds spacing between repositories for readability

Examples:
  $scriptname          # Checks all git repos in current directory
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

check-all-git-repos () {
	cdfirst=`pwd` 
	for i in *
	do
		cd "$i" && pwd && git status -sb && echo && echo
		cd "$cdfirst"
	done
}

    check-all-git-repos "$@" || help
}

main "$@" || help
trackusage.sh "$0"
