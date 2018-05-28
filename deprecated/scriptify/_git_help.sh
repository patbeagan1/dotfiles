_git_help () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "--all --guides --info --man --web";
            return
        ;;
    esac;
    __git_compute_all_commands;
    __gitcomp "$__git_all_commands $(__git_aliases)
		attributes cli core-tutorial cvs-migration
		diffcore everyday gitk glossary hooks ignore modules
		namespaces repository-layout revisions tutorial tutorial-2
		workflows
		"
}
if [[ $0 != "-bash" ]]; then _git_help "$@"; fi
