math () 
{ 
    echo "$*" | bc -l
}

if [[ "$1" = "-e" ]]; then shift; math "$@"; fi
