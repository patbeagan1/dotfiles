weather () 
{ 
    curl http://wttr.in/Boston
}

if [[ "$1" = "-e" ]]; then shift; weather "$@"; fi
