mergetest () 
{ 
    git merge --no-commit --no-ff "$1";
    git merge --abort;
    echo "Merge aborted"
}

if [[ "$1" = "-e" ]]; then shift; mergetest "$@"; fi
