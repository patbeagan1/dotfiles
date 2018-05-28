_git_grep () 
{ 
    __git_has_doubledash && return;
    case "$cur" in 
        --*)
            __gitcomp "
			--cached
			--text --ignore-case --word-regexp --invert-match
			--full-name --line-number
			--extended-regexp --basic-regexp --fixed-strings
			--perl-regexp
			--threads
			--files-with-matches --name-only
			--files-without-match
			--max-depth
			--count
			--and --or --not --all-match
			";
            return
        ;;
    esac;
    case "$cword,$prev" in 
        2,* | *,-*)
            if test -r tags; then
                __gitcomp_nl "$(__git_match_ctag "$cur" tags)";
                return;
            fi
        ;;
    esac;
    __gitcomp_nl "$(__git_refs)"
}
if [[ $0 != "-bash" ]]; then _git_grep "$@"; fi
