_git_rm () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "--cached --dry-run --ignore-unmatch --quiet";
            return
        ;;
    esac;
    __git_complete_index_file "--cached"
}
if [[ $0 != "-bash" ]]; then _git_rm "$@"; fi
