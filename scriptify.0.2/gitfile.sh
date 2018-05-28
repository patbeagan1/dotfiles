gitfile () 
{ 
    git status --porcelain | sed s/^...//
}

if [[ "$1" = "-e" ]]; then shift; gitfile "$@"; fi
