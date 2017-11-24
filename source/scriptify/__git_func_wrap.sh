__git_func_wrap () 
{ 
    local cur words cword prev;
    _get_comp_words_by_ref -n =: cur words cword prev;
    $1
}
if [[ $0 != "-bash" ]]; then __git_func_wrap "$@"; fi
