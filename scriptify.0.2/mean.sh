mean () 
{ 
    math $(sum "$1")/$(count_list "$1")
}

if [[ "$1" = "-e" ]]; then shift; mean "$@"; fi
