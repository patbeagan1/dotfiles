_git_push () 
{ 
    case "$prev" in 
        --repo)
            __gitcomp_nl "$(__git_remotes)";
            return
        ;;
        --recurse-submodules)
            __gitcomp "$__git_push_recurse_submodules";
            return
        ;;
    esac;
    case "$cur" in 
        --repo=*)
            __gitcomp_nl "$(__git_remotes)" "" "${cur##--repo=}";
            return
        ;;
        --recurse-submodules=*)
            __gitcomp "$__git_push_recurse_submodules" "" "${cur##--recurse-submodules=}";
            return
        ;;
        --force-with-lease=*)
            __git_complete_force_with_lease "${cur##--force-with-lease=}";
            return
        ;;
        --*)
            __gitcomp "
			--all --mirror --tags --dry-run --force --verbose
			--quiet --prune --delete --follow-tags
			--receive-pack= --repo= --set-upstream
			--force-with-lease --force-with-lease= --recurse-submodules=
		";
            return
        ;;
    esac;
    __git_complete_remote_or_refspec
}
if [[ $0 != "-bash" ]]; then _git_push "$@"; fi
