_get_comp_words_by_ref () 
{ 
    local exclude cur_ words_ cword_;
    if [ "$1" = "-n" ]; then
        exclude=$2;
        shift 2;
    fi;
    __git_reassemble_comp_words_by_ref "$exclude";
    cur_=${words_[cword_]};
    while [ $# -gt 0 ]; do
        case "$1" in 
            cur)
                cur=$cur_
            ;;
            prev)
                prev=${words_[$cword_-1]}
            ;;
            words)
                words=("${words_[@]}")
            ;;
            cword)
                cword=$cword_
            ;;
        esac;
        shift;
    done
}
if [[ $0 != "-bash" ]]; then _get_comp_words_by_ref "$@"; fi
