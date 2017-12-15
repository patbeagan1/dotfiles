checkcrlf () 
{ 
    dos2unix < "$1" | cmp -s - "$1"
}
if [[ $0 != "-bash" ]]; then checkcrlf "$@"; fi
