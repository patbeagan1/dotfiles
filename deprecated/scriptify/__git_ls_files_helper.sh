__git_ls_files_helper () 
{ 
    if [ "$2" == "--committable" ]; then
        git -C "$1" diff-index --name-only --relative HEAD;
    else
        git -C "$1" ls-files --exclude-standard $2;
    fi 2> /dev/null
}
if [[ $0 != "-bash" ]]; then __git_ls_files_helper "$@"; fi
