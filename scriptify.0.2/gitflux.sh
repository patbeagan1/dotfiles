gitflux () 
{ 
    for i in $(git ls-tree -r $(git rev-parse --abbrev-ref HEAD) --name-only);
    do
        echo $(git log --oneline $i | wc -l) $i;
    done
}

if [[ "$1" = "-e" ]]; then shift; gitflux "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
