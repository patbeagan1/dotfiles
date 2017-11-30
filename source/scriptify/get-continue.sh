get-continue () 
{ 
    read -sn 1 -p "Press any key to continue..."
}
if [[ $0 != "-bash" ]]; then get-continue "$@"; fi
