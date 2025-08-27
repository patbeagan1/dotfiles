#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <key_file>

Displays the randomart (ASCII art representation) of an SSH key.
Uses ssh-keygen to show the visual fingerprint of the key.

Arguments:
  key_file    Path to the SSH key file (public or private)

Features:
  - Shows ASCII art representation of SSH key fingerprint
  - Uses ssh-keygen -lv for detailed key information
  - Visual way to verify key fingerprints

Examples:
  $scriptname ~/.ssh/id_rsa.pub
  $scriptname ~/.ssh/id_ed25519
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
