__gitcomp_nl_append () 
{ 
    local IFS='
';
    __gitcompappend "$1" "${2-}" "${3-$cur}" "${4- }"
}
if [[ $0 != "-bash" ]]; then __gitcomp_nl_append "$@"; fi
