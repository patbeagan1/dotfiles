__git_complete_remote_or_refspec () 
{ 
    local cur_="$cur" cmd="${words[1]}";
    local i c=2 remote="" pfx="" lhs=1 no_complete_refspec=0;
    if [ "$cmd" = "remote" ]; then
        ((c++));
    fi;
    while [ $c -lt $cword ]; do
        i="${words[c]}";
        case "$i" in 
            --mirror)
                [ "$cmd" = "push" ] && no_complete_refspec=1
            ;;
            --all)
                case "$cmd" in 
                    push)
                        no_complete_refspec=1
                    ;;
                    fetch)
                        return
                    ;;
                    *)

                    ;;
                esac
            ;;
            -*)

            ;;
            *)
                remote="$i";
                break
            ;;
        esac;
        ((c++));
    done;
    if [ -z "$remote" ]; then
        __gitcomp_nl "$(__git_remotes)";
        return;
    fi;
    if [ $no_complete_refspec = 1 ]; then
        return;
    fi;
    [ "$remote" = "." ] && remote=;
    case "$cur_" in 
        *:*)
            case "$COMP_WORDBREAKS" in 
                *:*)
                    : great
                ;;
                *)
                    pfx="${cur_%%:*}:"
                ;;
            esac;
            cur_="${cur_#*:}";
            lhs=0
        ;;
        +*)
            pfx="+";
            cur_="${cur_#+}"
        ;;
    esac;
    case "$cmd" in 
        fetch)
            if [ $lhs = 1 ]; then
                __gitcomp_nl "$(__git_refs2 "$remote")" "$pfx" "$cur_";
            else
                __gitcomp_nl "$(__git_refs)" "$pfx" "$cur_";
            fi
        ;;
        pull | remote)
            if [ $lhs = 1 ]; then
                __gitcomp_nl "$(__git_refs "$remote")" "$pfx" "$cur_";
            else
                __gitcomp_nl "$(__git_refs)" "$pfx" "$cur_";
            fi
        ;;
        push)
            if [ $lhs = 1 ]; then
                __gitcomp_nl "$(__git_refs)" "$pfx" "$cur_";
            else
                __gitcomp_nl "$(__git_refs "$remote")" "$pfx" "$cur_";
            fi
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then __git_complete_remote_or_refspec "$@"; fi
