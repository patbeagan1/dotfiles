__gitk_main () 
{ 
    __git_has_doubledash && return;
    local g="$(__gitdir)";
    local merge="";
    if [ -f "$g/MERGE_HEAD" ]; then
        merge="--merge";
    fi;
    case "$cur" in 
        --*)
            __gitcomp "
			$__git_log_common_options
			$__git_log_gitk_options
			$merge
			";
            return
        ;;
    esac;
    __git_complete_revlist
}
if [[ $0 != "-bash" ]]; then __gitk_main "$@"; fi
