argcheck_base () 
{ 
    if [ "$1" -ne "$2" ]; then
        echo "Illegal number of parameters";
    fi
}
if [[ $0 != "-bash" ]]; then argcheck_base "$@"; fi
