dictionary () 
{ 
    curl dict://dict.org/d:$1
}

if [[ "$1" = "-e" ]]; then shift; dictionary "$@"; fi
