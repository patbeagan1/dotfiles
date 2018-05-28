getbranch () 
{ 
    printf $(git rev-parse --abbrev-ref HEAD)
}

if [[ "$1" = "-e" ]]; then shift; getbranch "$@"; fi
