rederr () 
{ 
    "$@" 2>&1 1>&3 | sed "s,.*,\033[31m&\e[0m," 1>&2
} 3>&1

if [[ "$1" = "-e" ]]; then shift; rederr "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
