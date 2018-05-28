killport () 
{ 
    sudo kill $(sudo lsof -t -i:$1)
}

if [[ "$1" = "-e" ]]; then shift; killport "$@"; fi
