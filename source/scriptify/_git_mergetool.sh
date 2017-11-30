_git_mergetool () 
{ 
    case "$cur" in 
        --tool=*)
            __gitcomp "$__git_mergetools_common tortoisemerge" "" "${cur##--tool=}";
            return
        ;;
        --*)
            __gitcomp "--tool=";
            return
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_mergetool "$@"; fi
