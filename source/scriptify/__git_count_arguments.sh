__git_count_arguments () 
{ 
    local word i c=0;
    for ((i=1; i < ${#words[@]}; i++))
    do
        word="${words[i]}";
        case "$word" in 
            --)
                ((c = 0))
            ;;
            "$1")
                ((c = 0))
            ;;
            ?*)
                ((c++))
            ;;
        esac;
    done;
    printf "%d" $c
}
if [[ $0 != "-bash" ]]; then __git_count_arguments "$@"; fi
