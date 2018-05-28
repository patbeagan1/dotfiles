lookbehind () 
{ 
    printf "((?!%s).)*" "$1"
}

if [[ "$1" = "-e" ]]; then shift; lookbehind "$@"; fi
