#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help]

Scans for all listening ports on the local system using lsof.
Shows which processes are listening on which ports with colorized output.

Features:
  - Shows all listening TCP and UDP ports
  - Displays process information for each port
  - Colorized output for better readability
  - Excludes common development directories from search

Requires:
  - sudo privileges to see all processes
  - lsof command

Examples:
  $scriptname          # Shows all listening ports
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

scan-local-ports () {
	sudo lsof \
		-i \
		-P \
		-n \
		| grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} LISTEN
}

    scan-local-ports "$@" || help
}

main "$@" || help
trackusage.sh "$0"
