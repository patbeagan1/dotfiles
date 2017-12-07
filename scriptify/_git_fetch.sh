_git_fetch () 
{ 
    case "$cur" in 
        --recurse-submodules=*)
            __gitcomp "$__git_fetch_recurse_submodules" "" "${cur##--recurse-submodules=}";
            return
        ;;
        --*)
            __gitcomp "$__git_fetch_options";
            return
        ;;
    esac;
    __git_complete_remote_or_refspec
}
if [[ $0 != "-bash" ]]; then _git_fetch "$@"; fi
