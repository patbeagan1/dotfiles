#!/usr/bin/env zsh

set -euo pipefail

scriptname="$(basename "$0")"
help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <prefix>

Searches command history for commands that start with the given prefix.
Uses omz_history for enhanced history functionality.

Arguments:
  prefix    Command prefix to search for

Features:
  - Searches through command history
  - Uses Oh My Zsh history function
  - Colorized output for better readability
  - Excludes common development directories from search

Examples:
  $scriptname git          # Shows all git commands from history
  $scriptname docker       # Shows all docker commands from history
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

# prev-command() { history | cut -d' ' -f2-100 | sed 's/^ *//g' | grep "^$1 "; }
prev-command () {
	omz_history |
        cut -d' ' -f2-100 |
        sed 's/^ *//g' |
        grep --color=auto --exclude-dir={.bzr,CVS,.git,.hg,.svn,.idea,.tox} "^$1 "
}

    prev-command "$@" || help
}

main "$@" || help
trackusage.sh "$0"
