gitflux () 
{ 
    for i in $(git ls-tree -r $(git rev-parse --abbrev-ref HEAD) --name-only);
    do
        echo $(git log --oneline $i | wc -l) $i;
    done
}

if [[ "$1" = "-e" ]]; then shift; gitflux "$@"; fi
