_git_bisect () 
{ 
    __git_has_doubledash && return;
    local subcommands="start bad good skip reset visualize replay log run";
    local subcommand="$(__git_find_on_cmdline "$subcommands")";
    if [ -z "$subcommand" ]; then
        if [ -f "$(__gitdir)"/BISECT_START ]; then
            __gitcomp "$subcommands";
        else
            __gitcomp "replay start";
        fi;
        return;
    fi;
    case "$subcommand" in 
        bad | good | reset | skip | start)
            __gitcomp_nl "$(__git_refs)"
        ;;
        *)

        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_bisect "$@"; fi
