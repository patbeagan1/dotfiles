__git_has_doubledash () 
{ 
    local c=1;
    while [ $c -lt $cword ]; do
        if [ "--" = "${words[c]}" ]; then
            return 0;
        fi;
        ((c++));
    done;
    return 1
}
if [[ $0 != "-bash" ]]; then __git_has_doubledash "$@"; fi
