argnum () 
{ 
    printf "%d args:" $#;
    printf " <%s>" "$@";
    echo
}
if [[ $0 != "-bash" ]]; then argnum "$@"; fi
