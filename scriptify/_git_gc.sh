_git_gc () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "--prune --aggressive";
            return
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_gc "$@"; fi
