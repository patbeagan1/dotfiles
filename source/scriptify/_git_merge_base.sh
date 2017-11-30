_git_merge_base () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "--octopus --independent --is-ancestor --fork-point";
            return
        ;;
    esac;
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_merge_base "$@"; fi
