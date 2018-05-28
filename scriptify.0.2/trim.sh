trim () 
{ 
    sed 's/^[ 	]*//;s/[ 	]*$//'
}

if [[ "$1" = "-e" ]]; then shift; trim "$@"; fi
