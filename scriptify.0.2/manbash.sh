manbash () 
{ 
    man -P "less '+/^ *'${1}" bash
}

if [[ "$1" = "-e" ]]; then shift; manbash "$@"; fi
