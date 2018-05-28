peek () 
{ 
    tree -L 2
}
if [[ $0 != "-bash" ]]; then peek "$@"; fi
