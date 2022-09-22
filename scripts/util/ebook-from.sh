#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

help () {
    error_code=$?
    echo "
No help message yet
"
    exit $error_code
}

ebook () {
	simplify-prose.sh -p "$1" > $1"".simplified.txt
	filesplit.py "$1".simplified.txt -------
    cd $(ls -1rt | tail -1)
    webringify.sh
    cd webring
    pwd
    python3 -m http.server
}

ebook "$@" || help
trackusage.sh "$0"
