mean () 
{ 
    math $(sum "$1")/$(count_list "$1")
}
if [[ $0 != "-bash" ]]; then mean "$@"; fi
