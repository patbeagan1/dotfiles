_git_format_patch () 
{ 
    case "$cur" in 
        --thread=*)
            __gitcomp "
			deep shallow
			" "" "${cur##--thread=}";
            return
        ;;
        --*)
            __gitcomp "$__git_format_patch_options";
            return
        ;;
    esac;
    __git_complete_revlist
}
if [[ $0 != "-bash" ]]; then _git_format_patch "$@"; fi
