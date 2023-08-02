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

randomart-of () {
	ssh-keygen -lv -f "$1"
}

    randomart-of "$@" || help
}

main "$@" || help
trackusage.sh "$0"
