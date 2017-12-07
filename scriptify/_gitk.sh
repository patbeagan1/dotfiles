_gitk () 
{ 
    __git_wrap__gitk_main
}
if [[ $0 != "-bash" ]]; then _gitk "$@"; fi
