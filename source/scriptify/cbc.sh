cbc () 
{ 
    git co "$1" && cd .. && ./clean && cd wayfair-android/
}
if [[ $0 != "-bash" ]]; then cbc "$@"; fi
