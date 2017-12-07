_git_bundle () 
{ 
    local cmd="${words[2]}";
    case "$cword" in 
        2)
            __gitcomp "create list-heads verify unbundle"
        ;;
        3)

        ;;
        *)
            case "$cmd" in 
                create)
                    __git_complete_revlist
                ;;
            esac
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_bundle "$@"; fi
