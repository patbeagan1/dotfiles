psp () 
{ 
    ps awwfux | less -S
}

if [[ "$1" = "-e" ]]; then shift; psp "$@"; fi
