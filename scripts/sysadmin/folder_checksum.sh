#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <directory>

Generates a SHA1 checksum for an entire directory by:
1. Finding all files in the directory recursively
2. Sorting them alphabetically
3. Computing SHA1 for each file
4. Concatenating all SHA1s and computing a final SHA1

This is useful for detecting changes in directory contents or verifying
directory integrity.

Arguments:
  directory    Path to the directory to checksum

Examples:
  $scriptname /path/to/directory
  $scriptname .
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
