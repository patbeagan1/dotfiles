lastfield () 
{ 
    awk -F "/" '{print $NF}'
}
if [[ $0 != "-bash" ]]; then lastfield "$@"; fi
