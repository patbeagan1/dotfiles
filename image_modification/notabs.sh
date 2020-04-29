notabs () 
{ 
    if [ $# -lt 2 ]; then
        echo "Usage: notabs <file> <num spaces to use>";
    else
        n="";
        for i in $(seq 1 $2);
        do
            n+=" ";
        done;
        sed "s/	/$n/g" $1;
    fi
}

if [[ "$1" = "-e" ]]; then shift; notabs "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
