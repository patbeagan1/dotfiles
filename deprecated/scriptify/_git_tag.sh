_git_tag () 
{ 
    local i c=1 f=0;
    while [ $c -lt $cword ]; do
        i="${words[c]}";
        case "$i" in 
            -d | -v)
                __gitcomp_nl "$(__git_tags)";
                return
            ;;
            -f)
                f=1
            ;;
        esac;
        ((c++));
    done;
    case "$prev" in 
        -m | -F)

        ;;
        -* | tag)
            if [ $f = 1 ]; then
                __gitcomp_nl "$(__git_tags)";
            fi
        ;;
        *)
            __gitcomp_nl "$(__git_refs)"
        ;;
    esac;
    case "$cur" in 
        --*)
            __gitcomp "
			--list --delete --verify --annotate --message --file
			--sign --cleanup --local-user --force --column --sort
			--contains --points-at
			"
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then _git_tag "$@"; fi
