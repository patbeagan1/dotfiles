ps_padding () 
{ 
    echo " $(date +"%H:%M:%S")$(parse_git_branch)" | tr "\n" " "
}
if [[ $0 != "-bash" ]]; then ps_padding "$@"; fi
