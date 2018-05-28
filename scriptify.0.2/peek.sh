peek () 
{ 
    tree -L 2
}

if [[ "$1" = "-e" ]]; then shift; peek "$@"; fi
