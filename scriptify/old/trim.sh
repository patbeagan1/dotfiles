trim () 
{ 
    sed 's/^[ 	]*//;s/[ 	]*$//'
}
if [[ $0 != "-bash" ]]; then trim "$@"; fi
