__git_compute_all_commands () 
{ 
    test -n "$__git_all_commands" || __git_all_commands=$(__git_list_all_commands)
}
if [[ $0 != "-bash" ]]; then __git_compute_all_commands "$@"; fi
