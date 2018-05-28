count_list () 
{ 
    echo "$1" | tr ',' '\n' | wc -l | tr '\n' ',' | sed s/,$//g
}
if [[ $0 != "-bash" ]]; then count_list "$@"; fi
