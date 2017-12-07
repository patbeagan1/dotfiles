__git_reassemble_comp_words_by_ref () 
{ 
    local exclude i j first;
    exclude="${1//[^$COMP_WORDBREAKS]}";
    cword_=$COMP_CWORD;
    if [ -z "$exclude" ]; then
        words_=("${COMP_WORDS[@]}");
        return;
    fi;
    for ((i=0, j=0; i < ${#COMP_WORDS[@]}; i++, j++))
    do
        first=t;
        while [ $i -gt 0 ] && [ -n "${COMP_WORDS[$i]}" ] && [ "${COMP_WORDS[$i]//[^$exclude]}" = "${COMP_WORDS[$i]}" ]; do
            if [ $j -ge 2 ] && [ -n "$first" ]; then
                ((j--));
            fi;
            first=;
            words_[$j]=${words_[j]}${COMP_WORDS[i]};
            if [ $i = $COMP_CWORD ]; then
                cword_=$j;
            fi;
            if (($i < ${#COMP_WORDS[@]} - 1)); then
                ((i++));
            else
                return;
            fi;
        done;
        words_[$j]=${words_[j]}${COMP_WORDS[i]};
        if [ $i = $COMP_CWORD ]; then
            cword_=$j;
        fi;
    done
}
if [[ $0 != "-bash" ]]; then __git_reassemble_comp_words_by_ref "$@"; fi
