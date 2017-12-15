_git_reflog () 
{ 
    local subcommands="show delete expire";
    local subcommand="$(__git_find_on_cmdline "$subcommands")";
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands";
    else
        __gitcomp_nl "$(__git_refs)";
    fi
}
if [[ $0 != "-bash" ]]; then _git_reflog "$@"; fi
