dictionary () 
{ 
    curl dict://dict.org/d:$1
}
if [[ $0 != "-bash" ]]; then dictionary "$@"; fi
