_git_commit () 
{ 
    case "$prev" in 
        -c | -C)
            __gitcomp_nl "$(__git_refs)" "" "${cur}";
            return
        ;;
    esac;
    case "$cur" in 
        --cleanup=*)
            __gitcomp "default scissors strip verbatim whitespace
			" "" "${cur##--cleanup=}";
            return
        ;;
        --reuse-message=* | --reedit-message=* | --fixup=* | --squash=*)
            __gitcomp_nl "$(__git_refs)" "" "${cur#*=}";
            return
        ;;
        --untracked-files=*)
            __gitcomp "$__git_untracked_file_modes" "" "${cur##--untracked-files=}";
            return
        ;;
        --*)
            __gitcomp "
			--all --author= --signoff --verify --no-verify
			--edit --no-edit
			--amend --include --only --interactive
			--dry-run --reuse-message= --reedit-message=
			--reset-author --file= --message= --template=
			--cleanup= --untracked-files --untracked-files=
			--verbose --quiet --fixup= --squash=
			";
            return
        ;;
    esac;
    if git rev-parse --verify --quiet HEAD > /dev/null; then
        __git_complete_index_file "--committable";
    else
        __git_complete_index_file "--cached";
    fi
}
if [[ $0 != "-bash" ]]; then _git_commit "$@"; fi
