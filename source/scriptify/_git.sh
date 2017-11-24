_git () 
{ 
    __git_wrap__git_main
}
if [[ $0 != "-bash" ]]; then _git "$@"; fi
