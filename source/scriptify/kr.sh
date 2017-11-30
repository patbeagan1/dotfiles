kr () 
{ 
    java -jar "$1"
}
if [[ $0 != "-bash" ]]; then kr "$@"; fi
