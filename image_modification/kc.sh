kc () 
{ 
    kotlinc "$1" -include-runtime -d out.jar
}

if [[ "$1" = "-e" ]]; then shift; kc "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
