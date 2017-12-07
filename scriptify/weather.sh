weather () 
{ 
    curl http://wttr.in/Boston
}
if [[ $0 != "-bash" ]]; then weather "$@"; fi
