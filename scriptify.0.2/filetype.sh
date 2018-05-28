filetype () 
{ 
    file * | sed s/,.*//
}

if [[ "$1" = "-e" ]]; then shift; filetype "$@"; fi
