_git_show_branch () 
{ 
    case "$cur" in 
        --*)
            __gitcomp "
			--all --remotes --topo-order --date-order --current --more=
			--list --independent --merge-base --no-name
			--color --no-color
			--sha1-name --sparse --topics --reflog
			";
            return
        ;;
    esac;
    __git_complete_revlist
}
if [[ $0 != "-bash" ]]; then _git_show_branch "$@"; fi
