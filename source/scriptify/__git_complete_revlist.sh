__git_complete_revlist () 
{ 
    __git_complete_revlist_file
}
if [[ $0 != "-bash" ]]; then __git_complete_revlist "$@"; fi
