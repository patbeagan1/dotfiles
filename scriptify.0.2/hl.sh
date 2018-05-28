hl () 
{ 
    grep --color=auto --color -i -E "$1|$" "$2"
}

if [[ "$1" = "-e" ]]; then shift; hl "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
