__gitcomp_nl () 
{ 
    COMPREPLY=();
    __gitcomp_nl_append "$@"
}
if [[ $0 != "-bash" ]]; then __gitcomp_nl "$@"; fi
