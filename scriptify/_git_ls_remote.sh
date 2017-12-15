_git_ls_remote () 
{ 
    __gitcomp_nl "$(__git_remotes)"
}
if [[ $0 != "-bash" ]]; then _git_ls_remote "$@"; fi
