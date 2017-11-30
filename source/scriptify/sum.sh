sum () 
{ 
    echo "$1" | tr ',' '+' | bc
}
if [[ $0 != "-bash" ]]; then sum "$@"; fi
