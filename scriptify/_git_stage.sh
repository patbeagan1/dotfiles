_git_stage () 
{ 
    _git_add
}
if [[ $0 != "-bash" ]]; then _git_stage "$@"; fi
