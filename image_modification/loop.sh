loop () 
{ 
    while :; do
        $*;
        sleep 0.5;
        if [ $1 == "-c" ]; then
            clear;
        fi;
    done
}

if [[ "$1" = "-e" ]]; then shift; loop "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
