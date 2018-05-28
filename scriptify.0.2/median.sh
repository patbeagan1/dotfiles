median () 
{ 
    echo -e "$1" | tr ',' '\n' | sort -n | awk '{arr[NR]=$1}
   END { if (NR%2==1) print arr[(NR+1)/2]; else print (arr[NR/2]+arr[NR/2+1])/2}'
}

if [[ "$1" = "-e" ]]; then shift; median "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
