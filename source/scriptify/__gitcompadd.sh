__gitcompadd () 
{ 
    COMPREPLY=();
    __gitcompappend "$@"
}
if [[ $0 != "-bash" ]]; then __gitcompadd "$@"; fi
