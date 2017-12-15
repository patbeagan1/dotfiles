_git_diff () 
{ 
    __git_has_doubledash && return;
    case "$cur" in 
        --diff-algorithm=*)
            __gitcomp "$__git_diff_algorithms" "" "${cur##--diff-algorithm=}";
            return
        ;;
        --submodule=*)
            __gitcomp "$__git_diff_submodule_formats" "" "${cur##--submodule=}";
            return
        ;;
        --*)
            __gitcomp "--cached --staged --pickaxe-all --pickaxe-regex
			--base --ours --theirs --no-index
			$__git_diff_common_options
			";
            return
        ;;
    esac;
    __git_complete_revlist_file
}
if [[ $0 != "-bash" ]]; then _git_diff "$@"; fi
