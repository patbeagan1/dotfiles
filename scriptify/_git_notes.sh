_git_notes () 
{ 
    local subcommands='add append copy edit list prune remove show';
    local subcommand="$(__git_find_on_cmdline "$subcommands")";
    case "$subcommand,$cur" in 
        ,--*)
            __gitcomp '--ref'
        ;;
        ,*)
            case "$prev" in 
                --ref)
                    __gitcomp_nl "$(__git_refs)"
                ;;
                *)
                    __gitcomp "$subcommands --ref"
                ;;
            esac
        ;;
        add,--reuse-message=* | append,--reuse-message=* | add,--reedit-message=* | append,--reedit-message=*)
            __gitcomp_nl "$(__git_refs)" "" "${cur#*=}"
        ;;
        add,--* | append,--*)
            __gitcomp '--file= --message= --reedit-message=
				--reuse-message='
        ;;
        copy,--*)
            __gitcomp '--stdin'
        ;;
        prune,--*)
            __gitcomp '--dry-run --verbose'
        ;;
        prune,*)

        ;;
        *)
            case "$prev" in 
                -m | -F)

                ;;
                *)
                    __gitcomp_nl "$(__git_refs)"
                ;;
            esac
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_notes "$@"; fi
