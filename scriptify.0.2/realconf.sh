realconf () 
{ 
    cat $1 | grep --color=auto --color=auto -v '#' | grep --color=auto --color=auto -v '^$'
}

if [[ "$1" = "-e" ]]; then shift; realconf "$@"; fi
