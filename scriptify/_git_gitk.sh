_git_gitk () 
{ 
    _gitk
}
if [[ $0 != "-bash" ]]; then _git_gitk "$@"; fi
