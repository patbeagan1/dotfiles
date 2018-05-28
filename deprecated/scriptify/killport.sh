killport () 
{ 
    sudo kill $(sudo lsof -t -i:$1)
}
if [[ $0 != "-bash" ]]; then killport "$@"; fi
