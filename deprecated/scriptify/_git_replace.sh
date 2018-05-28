_git_replace () 
{ 
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_replace "$@"; fi
