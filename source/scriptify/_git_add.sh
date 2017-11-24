_git_add () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "
			--interactive --refresh --patch --update --dry-run
			--ignore-errors --intent-to-add
			";
            return
        ;;
    esac;
    __git_complete_index_file "--others --modified --directory --no-empty-directory"
}
if [[ $0 != "-bash" ]]; then _git_add "$@"; fi
