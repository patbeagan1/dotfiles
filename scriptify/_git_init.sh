_git_init () 
{ 
    case "$cur" in 
        --shared=*)
            __gitcomp "
			false true umask group all world everybody
			" "" "${cur##--shared=}";
            return
        ;;
        --*)
            __gitcomp "--quiet --bare --template= --shared --shared=";
            return
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_init "$@"; fi
