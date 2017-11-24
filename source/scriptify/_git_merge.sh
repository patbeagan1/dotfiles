_git_merge () 
{ 
    __git_complete_strategy && return;
    case "$cur" in 
        --*)
            __gitcomp "$__git_merge_options
			--rerere-autoupdate --no-rerere-autoupdate --abort";
            return
        ;;
    esac;
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_merge "$@"; fi
