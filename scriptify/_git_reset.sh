_git_reset () 
{ 
    __git_has_doubledash && return;
    case "$cur" in 
        --*)
            __gitcomp "--merge --mixed --hard --soft --patch";
            return
        ;;
    esac;
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_reset "$@"; fi
