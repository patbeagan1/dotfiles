_git_ls_files () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "--cached --deleted --modified --others --ignored
			--stage --directory --no-empty-directory --unmerged
			--killed --exclude= --exclude-from=
			--exclude-per-directory= --exclude-standard
			--error-unmatch --with-tree= --full-name
			--abbrev --ignored --exclude-per-directory
			";
            return
        ;;
    esac;
    __git_complete_index_file "--cached"
}
if [[ $0 != "-bash" ]]; then _git_ls_files "$@"; fi
