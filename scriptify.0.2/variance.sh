variance () 
{ 
    math $(sum $(echo $(for i in $(echo "$1" | tr ',' ' '); do math $(math $i-$(mean "$1"))^2; done) | tr ' ' ',')) / $(count_list "$1")
}

if [[ "$1" = "-e" ]]; then shift; variance "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
