_git_clean () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "--dry-run --quiet";
            return
        ;;
    esac;
    __git_complete_index_file "--others --directory"
}
if [[ $0 != "-bash" ]]; then _git_clean "$@"; fi
