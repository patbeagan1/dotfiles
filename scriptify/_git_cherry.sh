_git_cherry () 
{ 
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_cherry "$@"; fi
