_git_worktree () 
{ 
    local subcommands="add list lock prune unlock";
    local subcommand="$(__git_find_on_cmdline "$subcommands")";
    if [ -z "$subcommand" ]; then
        __gitcomp "$subcommands";
    else
        case "$subcommand,$cur" in 
            add,--*)
                __gitcomp "--detach"
            ;;
            list,--*)
                __gitcomp "--porcelain"
            ;;
            lock,--*)
                __gitcomp "--reason"
            ;;
            prune,--*)
                __gitcomp "--dry-run --expire --verbose"
            ;;
            *)

            ;;
        esac;
    fi
}
if [[ $0 != "-bash" ]]; then _git_worktree "$@"; fi
