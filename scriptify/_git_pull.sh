_git_pull () 
{ 
    __git_complete_strategy && return;
    case "$cur" in 
        --recurse-submodules=*)
            __gitcomp "$__git_fetch_recurse_submodules" "" "${cur##--recurse-submodules=}";
            return
        ;;
        --*)
            __gitcomp "
			--rebase --no-rebase
			$__git_merge_options
			$__git_fetch_options
		";
            return
        ;;
    esac;
    __git_complete_remote_or_refspec
}
if [[ $0 != "-bash" ]]; then _git_pull "$@"; fi
