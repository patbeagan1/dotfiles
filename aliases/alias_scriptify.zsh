scriptify() {
    create_header() {
        echo '
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
'
    }
    create_parser() {
        echo '
    emulate -L zsh
    zmodload zsh/zutil || return 1

    local help
    zparseopts -D -F -K -- \
        {h,-help}=help ||
        return 1

    if (($#help)); then help; fi
'
    }

    # ==============================================================

    if [[ "$(which "$1")" == *": shell reserved word" ]]; then
        echo This is a shell builtin.
    elif [[ "$(which "$1")" == *": aliased to"* ]]; then
        echo This is an alias.
    else
        # ==============================================================

        # Printing out the contents of the function to a file and making it executable
        echo '#!/usr/bin/env zsh' >"$1".sh &&
            if test $?; then
                chmod 755 "$1".sh
                which "$1" | cat
                create_header >>"$1".sh
                echo "main() {" >>"$1".sh
                create_parser >>"$1".sh
                which "$1" >>"$1".sh
                echo >>"$1".sh
                echo "    $1" '"$@" || help' >>"$1".sh
                echo "}\n" >>"$1".sh
                echo 'main "$@" || help' >>"$1".sh
                echo 'trackusage.sh "$0"' >>"$1".sh
            fi

    fi
}
