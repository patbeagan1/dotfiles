_git_log () 
{ 
    __git_has_doubledash && return;
    local g="$(git rev-parse --git-dir 2>/dev/null)";
    local merge="";
    if [ -f "$g/MERGE_HEAD" ]; then
        merge="--merge";
    fi;
    case "$cur" in 
        --pretty=* | --format=*)
            __gitcomp "$__git_log_pretty_formats $(__git_pretty_aliases)
			" "" "${cur#*=}";
            return
        ;;
        --date=*)
            __gitcomp "$__git_log_date_formats" "" "${cur##--date=}";
            return
        ;;
        --decorate=*)
            __gitcomp "full short no" "" "${cur##--decorate=}";
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
            __gitcomp "
			$__git_log_common_options
			$__git_log_shortlog_options
			$__git_log_gitk_options
			--root --topo-order --date-order --reverse
			--follow --full-diff
			--abbrev-commit --abbrev=
			--relative-date --date=
			--pretty= --format= --oneline
			--show-signature
			--cherry-mark
			--cherry-pick
			--graph
			--decorate --decorate=
			--walk-reflogs
			--parents --children
			$merge
			$__git_diff_common_options
			--pickaxe-all --pickaxe-regex
			";
            return
        ;;
    esac;
    __git_complete_revlist
}
if [[ $0 != "-bash" ]]; then _git_log "$@"; fi
