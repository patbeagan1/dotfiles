__git_complete_strategy () 
{ 
    __git_compute_merge_strategies;
    case "$prev" in 
        -s | --strategy)
            __gitcomp "$__git_merge_strategies";
            return 0
        ;;
    esac;
    case "$cur" in 
        --strategy=*)
            __gitcomp "$__git_merge_strategies" "" "${cur##--strategy=}";
            return 0
        ;;
    esac;
    return 1
}
if [[ $0 != "-bash" ]]; then __git_complete_strategy "$@"; fi
