argnum () 
{ 
    printf "%d args:" $#;
    printf " <%s>" "$@";
    echo
}