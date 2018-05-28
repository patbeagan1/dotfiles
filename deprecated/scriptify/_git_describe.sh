_git_describe () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "
			--all --tags --contains --abbrev= --candidates=
			--exact-match --debug --long --match --always
			";
            return
        ;;
    esac;
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_describe "$@"; fi
