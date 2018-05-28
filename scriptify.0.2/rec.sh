rec () 
{ 
    script ~/Downloads/typescript-`date | sed 's/ /-/g'`.log;
    history > ~/Downloads/"$(echo "history-`date`.log" | sed s/\ /_/g)"
}

if [[ "$1" = "-e" ]]; then shift; rec "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
