mergetest () 
{ 
    git merge --no-commit --no-ff "$1";
    git merge --abort;
    echo "Merge aborted"
}
if [[ $0 != "-bash" ]]; then mergetest "$@"; fi
