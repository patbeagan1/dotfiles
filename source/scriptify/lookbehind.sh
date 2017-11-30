lookbehind () 
{ 
    printf "((?!%s).)*" "$1"
}
if [[ $0 != "-bash" ]]; then lookbehind "$@"; fi
