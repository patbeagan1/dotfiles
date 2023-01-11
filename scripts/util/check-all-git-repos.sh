#!/usr/bin/env zsh

set -euo pipefail

scriptname="$0"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

No help message yet
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
