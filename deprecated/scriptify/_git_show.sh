_git_show () 
{ 
    __git_has_doubledash && return;
    case "$cur" in 
        --pretty=* | --format=*)
            __gitcomp "$__git_log_pretty_formats $(__git_pretty_aliases)
			" "" "${cur#*=}";
            return
        ;;
        --diff-algorithm=*)
            __gitcomp "$__git_diff_algorithms" "" "${cur##--diff-algorithm=}";
            return
        ;;
        --submodule=*)
            __gitcomp "$__git_diff_submodule_formats" "" "${cur##--submodule=}";
            return
        ;;
        --*)
            __gitcomp "--pretty= --format= --abbrev-commit --oneline
			--show-signature
			$__git_diff_common_options
			";
            return
        ;;
    esac;
    __git_complete_revlist_file
}
if [[ $0 != "-bash" ]]; then _git_show "$@"; fi
