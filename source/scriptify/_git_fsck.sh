_git_fsck () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "
			--tags --root --unreachable --cache --no-reflogs --full
			--strict --verbose --lost-found
			";
            return
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_fsck "$@"; fi
