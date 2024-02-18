#!/usr/bin/env zsh

set -euo pipefail

scriptname="$0"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

This is used to merge other projects back into the incubator.
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

merge-project () {
	if [ $# -ne 2 ]
	then
		echo 'requires <repo> <default-branch>'
		return 1
	fi
	git remote add -f repo-"$1" git@github.com:patbeagan1/"$1".git
	git merge repo-"$1"/"$2" --allow-unrelated-histories
}

    merge-project "$@" || help
}

main "$@" || help
trackusage.sh "$0"
