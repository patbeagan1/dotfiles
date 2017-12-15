_git_mv () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "--dry-run";
            return
        ;;
    esac;
    if [ $(__git_count_arguments "mv") -gt 0 ]; then
        __git_complete_index_file "--cached --others --directory";
    else
        __git_complete_index_file "--cached";
    fi
}
if [[ $0 != "-bash" ]]; then _git_mv "$@"; fi
