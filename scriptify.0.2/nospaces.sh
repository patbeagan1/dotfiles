nospaces () 
{ 
    rename 'y/ /_/' *
}

if [[ "$1" = "-e" ]]; then shift; nospaces "$@"; fi
