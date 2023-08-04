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

cat-ansifile () {
	iconv -f "windows-1252" -t "UTF-8" "$1" -o /tmp/ansi-out.txt && perl -pe "system 'sleep .005'" /tmp/ansi-out.txt 
}

    cat-ansifile "$@" || help
}

main "$@" || help
trackusage.sh "$0"
