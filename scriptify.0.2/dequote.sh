dequote () 
{ 
    eval printf %s "$1" 2> /dev/null
}

if [[ "$1" = "-e" ]]; then shift; dequote "$@"; fi
