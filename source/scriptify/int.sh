int () 
{ 
    if [ "$2" != "=" ]; then
        echo Error: bad assignment "$1";
    else
        declare -i "$1"="$3";
    fi
}
if [[ $0 != "-bash" ]]; then int "$@"; fi
