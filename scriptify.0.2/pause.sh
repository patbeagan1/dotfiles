pause () 
{ 
    read -p "$*"
}

if [[ "$1" = "-e" ]]; then shift; pause "$@"; fi
