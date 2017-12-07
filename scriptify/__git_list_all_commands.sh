__git_list_all_commands () 
{ 
    local i IFS=" "'
';
    for i in $(__git_commands);
    do
        case $i in 
            *--*)
                : helper pattern
            ;;
            *)
                echo $i
            ;;
        esac;
    done
}
if [[ $0 != "-bash" ]]; then __git_list_all_commands "$@"; fi
