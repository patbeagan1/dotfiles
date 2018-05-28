release () 
{ 
    echo release-v4."$1"
}

if [[ "$1" = "-e" ]]; then shift; release "$@"; fi
