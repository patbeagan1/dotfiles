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

folder_checksum () {
	find "$1" -type f -print0 | sort -z | xargs -0 sha1sum | cut -c1-40 | sha1sum
}

    folder_checksum "$@" || help
}

main "$@" || help
trackusage.sh "$0"
