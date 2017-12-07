_git_name_rev () 
{ 
    __gitcomp "--tags --all --stdin"
}
if [[ $0 != "-bash" ]]; then _git_name_rev "$@"; fi
