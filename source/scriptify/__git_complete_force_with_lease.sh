__git_complete_force_with_lease () 
{ 
    local cur_=$1;
    case "$cur_" in 
        --*=)

        ;;
        *:*)
            __gitcomp_nl "$(__git_refs)" "" "${cur_#*:}"
        ;;
        *)
            __gitcomp_nl "$(__git_refs)" "" "$cur_"
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then __git_complete_force_with_lease "$@"; fi
