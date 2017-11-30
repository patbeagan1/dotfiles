__git_compute_porcelain_commands () 
{ 
    test -n "$__git_porcelain_commands" || __git_porcelain_commands=$(__git_list_porcelain_commands)
}
if [[ $0 != "-bash" ]]; then __git_compute_porcelain_commands "$@"; fi
