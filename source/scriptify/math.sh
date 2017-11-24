math () 
{ 
    echo "$*" | bc -l
}
if [[ $0 != "-bash" ]]; then math "$@"; fi
