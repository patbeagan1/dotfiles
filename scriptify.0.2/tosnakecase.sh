tosnakecase () 
{ 
    echo "$1" | perl -pe 's/([a-z0-9])([A-Z])/$1_\L$2/g'
}

if [[ "$1" = "-e" ]]; then shift; tosnakecase "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
