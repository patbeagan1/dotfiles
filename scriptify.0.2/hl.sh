hl () 
{ 
    grep --color=auto --color -i -E "$1|$" "$2"
}

if [[ "$1" = "-e" ]]; then shift; hl "$@"; fi
