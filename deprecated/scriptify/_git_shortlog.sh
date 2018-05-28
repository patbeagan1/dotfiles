_git_shortlog () 
{ 
    __git_has_doubledash && return;
    case "$cur" in 
        --*)
            __gitcomp "
			$__git_log_common_options
			$__git_log_shortlog_options
			--numbered --summary
			";
            return
        ;;
    esac;
    __git_complete_revlist
}
if [[ $0 != "-bash" ]]; then _git_shortlog "$@"; fi
