#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <url>

Displays ANSI content from a remote URL with proper encoding and visual effects.
Downloads the content from the URL and displays it using cat-ansifile.sh.

Arguments:
  url    Remote URL containing ANSI content

Features:
  - Downloads content from remote URL using curl
  - Clears screen before displaying (ESC c)
  - Uses cat-ansifile.sh for proper encoding and display effects
  - Handles remote ANSI art and BBS-style content

Examples:
  $scriptname http://example.com/ansi_art.txt
  $scriptname https://bbs.example.com/art.ans
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

cat-ansi-remote () {
	cat-ansifile.sh <(printf "\033c" && curl -sS "$1")
}

    cat-ansi-remote "$@" || help
}

main "$@" || help
trackusage.sh "$0"
