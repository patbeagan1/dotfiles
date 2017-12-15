__gitcompappend () 
{ 
    local x i=${#COMPREPLY[@]};
    for x in $1;
    do
        if [[ "$x" == "$3"* ]]; then
            COMPREPLY[i++]="$2$x$4";
        fi;
    done
}
if [[ $0 != "-bash" ]]; then __gitcompappend "$@"; fi
