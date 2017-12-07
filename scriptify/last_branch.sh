last_branch () 
{ 
    git branch --sort=committerdate
}
if [[ $0 != "-bash" ]]; then last_branch "$@"; fi
