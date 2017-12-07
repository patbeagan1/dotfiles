_git_stash () 
{ 
    local save_opts='--all --keep-index --no-keep-index --quiet --patch --include-untracked';
    local subcommands='save list show apply clear drop pop create branch';
    local subcommand="$(__git_find_on_cmdline "$subcommands")";
    if [ -z "$subcommand" ]; then
        case "$cur" in 
            --*)
                __gitcomp "$save_opts"
            ;;
            *)
                if [ -z "$(__git_find_on_cmdline "$save_opts")" ]; then
                    __gitcomp "$subcommands";
                fi
            ;;
        esac;
    else
        case "$subcommand,$cur" in 
            save,--*)
                __gitcomp "$save_opts"
            ;;
            apply,--* | pop,--*)
                __gitcomp "--index --quiet"
            ;;
            drop,--*)
                __gitcomp "--quiet"
            ;;
            show,--* | branch,--*)

            ;;
            branch,*)
                if [ $cword -eq 3 ]; then
                    __gitcomp_nl "$(__git_refs)";
                else
                    __gitcomp_nl "$(git --git-dir="$(__gitdir)" stash list 						| sed -n -e 's/:.*//p')";
                fi
            ;;
            show,* | apply,* | drop,* | pop,*)
                __gitcomp_nl "$(git --git-dir="$(__gitdir)" stash list 					| sed -n -e 's/:.*//p')"
            ;;
            *)

            ;;
        esac;
    fi
}
if [[ $0 != "-bash" ]]; then _git_stash "$@"; fi
