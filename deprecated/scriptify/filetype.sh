filetype () 
{ 
    file * | sed s/,.*//
}
if [[ $0 != "-bash" ]]; then filetype "$@"; fi
