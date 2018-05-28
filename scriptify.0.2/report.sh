report () 
{ 
    loop "clear; df; echo; w; echo; ps -e -o pcpu -o ruser -o args|sort -nr|grep -v %CPU|head -1; sleep 5"
}

if [[ "$1" = "-e" ]]; then shift; report "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
