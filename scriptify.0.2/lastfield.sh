lastfield () 
{ 
    awk -F "/" '{print $NF}'
}

if [[ "$1" = "-e" ]]; then shift; lastfield "$@"; fi
