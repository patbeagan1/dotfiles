sort_list () 
{ 
    echo "$1" | tr ',' '\n' | sort | tr '\n' ',' | sed s/,$//g
}
if [[ $0 != "-bash" ]]; then sort_list "$@"; fi
