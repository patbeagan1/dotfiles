cputemp () 
{ 
    if isMac; then
        c=$(iStats | grep 'CPU temp' | sed s/[a-zA-Z\ :]*// | sed s/°.*//);
        echo "9*$c/5+32" | bc -l;
    fi
}

if [[ "$1" = "-e" ]]; then shift; cputemp "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
