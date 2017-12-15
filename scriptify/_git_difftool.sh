_git_difftool () 
{ 
    __git_has_doubledash && return;
    case "$cur" in 
        --tool=*)
            __gitcomp "$__git_mergetools_common kompare" "" "${cur##--tool=}";
            return
        ;;
        --*)
            __gitcomp "--cached --staged --pickaxe-all --pickaxe-regex
			--base --ours --theirs
			--no-renames --diff-filter= --find-copies-harder
			--relative --ignore-submodules
			--tool=";
            return
        ;;
    esac;
    __git_complete_revlist_file
}
if [[ $0 != "-bash" ]]; then _git_difftool "$@"; fi
