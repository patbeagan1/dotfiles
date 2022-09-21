scriptify() {
    create_header() {
        cat <<EOF

set -euo pipefail
IFS=$'\n\t'

help () {
    error_code=\$?
    echo "
No help message yet
"
    exit \$error_code
}

EOF
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
                which "$1" >>"$1".sh
                echo >>"$1".sh
                echo "$1" '"$@" || help' >>"$1".sh
                echo 'trackusage.sh "$0"' >>"$1".sh
            fi

    fi
}
