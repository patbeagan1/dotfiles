_git_ls_tree () 
{ 
    __git_complete_file
}
if [[ $0 != "-bash" ]]; then _git_ls_tree "$@"; fi
