__git_compute_merge_strategies () 
{ 
    test -n "$__git_merge_strategies" || __git_merge_strategies=$(__git_list_merge_strategies)
}
if [[ $0 != "-bash" ]]; then __git_compute_merge_strategies "$@"; fi
