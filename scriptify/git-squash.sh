git-squash () 
{ 
    TIME=$(date +%s);
    BRANCH=$(git rev-parse --abbrev-ref HEAD);
    git branch -m $BRANCH.$TIME;
    git checkout master;
    git checkout -b $BRANCH;
    git merge --squash $BRANCH.$TIME;
    git status
}
if [[ $0 != "-bash" ]]; then git-squash "$@"; fi
