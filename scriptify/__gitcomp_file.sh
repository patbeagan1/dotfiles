__gitcomp_file () 
{ 
    local IFS='
';
    __gitcompadd "$1" "${2-}" "${3-$cur}" "";
    compopt -o filenames +o nospace 2> /dev/null || compgen -f /non-existing-dir/ > /dev/null
}
if [[ $0 != "-bash" ]]; then __gitcomp_file "$@"; fi
