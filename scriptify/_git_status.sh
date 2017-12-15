_git_status () 
{ 
    local complete_opt;
    local untracked_state;
    case "$cur" in 
        --ignore-submodules=*)
            __gitcomp "none untracked dirty all" "" "${cur##--ignore-submodules=}";
            return
        ;;
        --untracked-files=*)
            __gitcomp "$__git_untracked_file_modes" "" "${cur##--untracked-files=}";
            return
        ;;
        --column=*)
            __gitcomp "
			always never auto column row plain dense nodense
			" "" "${cur##--column=}";
            return
        ;;
        --*)
            __gitcomp "
			--short --branch --porcelain --long --verbose
			--untracked-files= --ignore-submodules= --ignored
			--column= --no-column
			";
            return
        ;;
    esac;
    untracked_state="$(__git_get_option_value "-u" "--untracked-files=" 		"$__git_untracked_file_modes" "status.showUntrackedFiles")";
    case "$untracked_state" in 
        no)
            complete_opt=
        ;;
        all | normal | *)
            complete_opt="--cached --directory --no-empty-directory --others";
            if [ -n "$(__git_find_on_cmdline "--ignored")" ]; then
                complete_opt="$complete_opt --ignored --exclude=*";
            fi
        ;;
    esac;
    __git_complete_index_file "$complete_opt"
}
if [[ $0 != "-bash" ]]; then _git_status "$@"; fi
