_git_submodule () 
{ 
    __git_has_doubledash && return;
    local subcommands="add status init deinit update summary foreach sync";
    if [ -z "$(__git_find_on_cmdline "$subcommands")" ]; then
        case "$cur" in 
            --*)
                __gitcomp "--quiet --cached"
            ;;
            *)
                __gitcomp "$subcommands"
            ;;
        esac;
        return;
    fi
}
if [[ $0 != "-bash" ]]; then _git_submodule "$@"; fi
