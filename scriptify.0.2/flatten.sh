flatten () 
{ 
    test -d __flattened_files || mkdir __flattened_files;
    which gmv > /dev/null && find "$1" -type f -exec gmv --backup=numbered $(echo '{}') __flattened_files \;
}

if [[ "$1" = "-e" ]]; then shift; flatten "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
