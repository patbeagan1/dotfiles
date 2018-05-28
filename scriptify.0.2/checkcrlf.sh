checkcrlf () 
{ 
    dos2unix < "$1" | cmp -s - "$1"
}

if [[ "$1" = "-e" ]]; then shift; checkcrlf "$@"; fi
