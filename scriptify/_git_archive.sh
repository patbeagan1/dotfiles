_git_archive () 
{ 
    case "$cur" in 
        --format=*)
            __gitcomp "$(git archive --list)" "" "${cur##--format=}";
            return
        ;;
        --remote=*)
            __gitcomp_nl "$(__git_remotes)" "" "${cur##--remote=}";
            return
        ;;
        --*)
            __gitcomp "
			--format= --list --verbose
			--prefix= --remote= --exec=
			";
            return
        ;;
    esac;
    __git_complete_file
}
if [[ $0 != "-bash" ]]; then _git_archive "$@"; fi
