sum () 
{ 
    echo "$1" | tr ',' '+' | bc
}

if [[ "$1" = "-e" ]]; then shift; sum "$@"; fi
