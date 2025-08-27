#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <file>

Displays an ANSI file with proper encoding conversion and visual effects.
Converts Windows-1252 encoding to UTF-8 and displays the content with
a small delay between lines for a retro terminal effect.

Arguments:
  file    Path to the ANSI file to display

Features:
  - Converts Windows-1252 to UTF-8 encoding
  - Adds visual delay between lines (0.005 seconds)
  - Creates a retro terminal viewing experience

Examples:
  $scriptname retro.ans
  $scriptname /path/to/ansi_file.txt
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
