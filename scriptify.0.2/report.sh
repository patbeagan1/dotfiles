report () 
{ 
    loop "clear; df; echo; w; echo; ps -e -o pcpu -o ruser -o args|sort -nr|grep -v %CPU|head -1; sleep 5"
}

if [[ "$1" = "-e" ]]; then shift; report "$@"; fi