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

function f () {
  emulate -L zsh
  zmodload zsh/zutil || return

  # Default option values can be specified as (value).
  local help verbose message file=(default)

  # Brace expansions are great for specifying short and long
  # option names without duplicating any information.
  zparseopts -D -F -K -- \
    {h,-help}=help       \
    {v,-verbose}=verbose \
    {f,-file}:=file || return
  # zparseopts prints an error message if it cannot parse
  # arguments, so we can simply return on error.

  if (( $#help )); then
    print -rC1 --      \
      "$0 [-h|--help]" \
      "$0 [-v|--verbose] [-f|--file=<file>] [<message...>]"
    return
  fi

  # Presence of options can be checked via (( $#option )).
  if (( $#verbose )); then
    print verbose
  fi

  # Values of options can be retrieved through $option[-1].
  print -r -- "file: ${(q+)file[-1]}"

  # Positional arguments are in $@.
  print -rC1 -- "message: "${(q+)^@}	
}

f "$@" || help
trackusage.sh "$0"
