hl () 
{ 
    grep --color=auto --color -i -E "$1|$" "$2"
}
