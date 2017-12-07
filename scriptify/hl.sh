hl () 
{ 
    grep --color=auto --color -i -E "$1|$" "$2"
}
if [[ $0 != "-bash" ]]; then hl "$@"; fi
