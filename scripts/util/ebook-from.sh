#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

scriptname="$(basename "$0")"

help () {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <file>

Converts a text file into a web-based ebook with simplified prose and webring navigation.
Creates a local web server to view the ebook in a browser.

Process:
1. Simplifies the prose using simplify-prose.sh
2. Splits the content into sections using filesplit.py
3. Creates HTML pages with webring navigation
4. Starts a local HTTP server to view the ebook

Arguments:
  file    Text file to convert to ebook format

Examples:
  $scriptname book.txt
  $scriptname /path/to/story.txt
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
