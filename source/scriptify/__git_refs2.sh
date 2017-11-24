__git_refs2 () 
{ 
    local i;
    for i in $(__git_refs "$1");
    do
        echo "$i:$i";
    done
}
if [[ $0 != "-bash" ]]; then __git_refs2 "$@"; fi
