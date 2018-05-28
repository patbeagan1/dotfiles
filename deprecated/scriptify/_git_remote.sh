_git_remote () 
{ 
    local subcommands="add rename remove set-head set-branches set-url show prune update";
    local subcommand="$(__git_find_on_cmdline "$subcommands")";
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands";
        return;
    fi;
    case "$subcommand" in 
        rename | remove | set-url | show | prune)
            __gitcomp_nl "$(__git_remotes)"
        ;;
        set-head | set-branches)
            __git_complete_remote_or_refspec
        ;;
        update)
            __gitcomp "$(__git_get_config_variables "remotes")"
        ;;
        *)

        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_remote "$@"; fi
