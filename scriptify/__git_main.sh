__git_main () 
{ 
    local i c=1 command __git_dir;
    while [ $c -lt $cword ]; do
        i="${words[c]}";
        case "$i" in 
            --git-dir=*)
                __git_dir="${i#--git-dir=}"
            ;;
            --git-dir)
                ((c++));
                __git_dir="${words[c]}"
            ;;
            --bare)
                __git_dir="."
            ;;
            --help)
                command="help";
                break
            ;;
            -c | --work-tree | --namespace)
                ((c++))
            ;;
            -*)

            ;;
            *)
                command="$i";
                break
            ;;
        esac;
        ((c++));
    done;
    if [ -z "$command" ]; then
        case "$cur" in 
            --*)
                __gitcomp "
			--paginate
			--no-pager
			--git-dir=
			--bare
			--version
			--exec-path
			--exec-path=
			--html-path
			--man-path
			--info-path
			--work-tree=
			--namespace=
			--no-replace-objects
			--help
			"
            ;;
            *)
                __git_compute_porcelain_commands;
                __gitcomp "$__git_porcelain_commands $(__git_aliases)"
            ;;
        esac;
        return;
    fi;
    local completion_func="_git_${command//-/_}";
    declare -f $completion_func > /dev/null && $completion_func && return;
    local expansion=$(__git_aliased_command "$command");
    if [ -n "$expansion" ]; then
        words[1]=$expansion;
        completion_func="_git_${expansion//-/_}";
        declare -f $completion_func > /dev/null && $completion_func;
    fi
}
if [[ $0 != "-bash" ]]; then __git_main "$@"; fi
