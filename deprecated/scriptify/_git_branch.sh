_git_branch () 
{ 
    local i c=1 only_local_ref="n" has_r="n";
    while [ $c -lt $cword ]; do
        i="${words[c]}";
        case "$i" in 
            -d | --delete | -m | --move)
                only_local_ref="y"
            ;;
            -r | --remotes)
                has_r="y"
            ;;
        esac;
        ((c++));
    done;
    case "$cur" in 
        --set-upstream-to=*)
            __gitcomp_nl "$(__git_refs)" "" "${cur##--set-upstream-to=}"
        ;;
        --*)
            __gitcomp "
			--color --no-color --verbose --abbrev= --no-abbrev
			--track --no-track --contains --merged --no-merged
			--set-upstream-to= --edit-description --list
			--unset-upstream --delete --move --remotes
			"
        ;;
        *)
            if [ $only_local_ref = "y" -a $has_r = "n" ]; then
                __gitcomp_nl "$(__git_heads)";
            else
                __gitcomp_nl "$(__git_refs)";
            fi
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_branch "$@"; fi
