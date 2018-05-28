gitsync () 
{ 
    git fetch origin "$1":"$1"
}

if [[ "$1" = "-e" ]]; then shift; gitsync "$@"; fi
