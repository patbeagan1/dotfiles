__git_complete_index_file () 
{ 
    local pfx="" cur_="$cur";
    case "$cur_" in 
        ?*/*)
            pfx="${cur_%/*}";
            cur_="${cur_##*/}";
            pfx="${pfx}/"
        ;;
    esac;
    __gitcomp_file "$(__git_index_files "$1" ${pfx:+"$pfx"})" "$pfx" "$cur_"
}
if [[ $0 != "-bash" ]]; then __git_complete_index_file "$@"; fi
