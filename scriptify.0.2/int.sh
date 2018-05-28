int () 
{ 
    if [ "$2" != "=" ]; then
        echo Error: bad assignment "$1";
    else
        declare -i "$1"="$3";
    fi
}

if [[ "$1" = "-e" ]]; then shift; int "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
