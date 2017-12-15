_git_whatchanged () 
{ 
    _git_log
}
if [[ $0 != "-bash" ]]; then _git_whatchanged "$@"; fi
