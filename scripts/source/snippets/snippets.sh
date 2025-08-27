#!/bin/zsh
function main() {
  local filename=""
  if [ -z "$1" ]; then 
	  filename="snippet.txt"
  else
	  filename="$1"
  fi
  eval "$(fzf < "$filename")"
}
main "$@"
