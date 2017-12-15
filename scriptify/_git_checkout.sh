_git_checkout () 
{ 
    __git_has_doubledash && return;
    case "$cur" in 
        --conflict=*)
            __gitcomp "diff3 merge" "" "${cur##--conflict=}"
        ;;
        --*)
            __gitcomp "
			--quiet --ours --theirs --track --no-track --merge
			--conflict= --orphan --patch
			"
        ;;
        *)
            local flags="--track --no-track --no-guess" track=1;
            if [ -n "$(__git_find_on_cmdline "$flags")" ]; then
                track='';
            fi;
            __gitcomp_nl "$(__git_refs '' $track)"
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_checkout "$@"; fi
