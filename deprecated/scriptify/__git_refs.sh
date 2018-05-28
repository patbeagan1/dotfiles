__git_refs () 
{ 
    local i hash dir="$(__gitdir "${1-}")" track="${2-}";
    local format refs pfx;
    if [ -d "$dir" ]; then
        case "$cur" in 
            refs | refs/*)
                format="refname";
                refs="${cur%/*}";
                track=""
            ;;
            *)
                [[ "$cur" == ^* ]] && pfx="^";
                for i in HEAD FETCH_HEAD ORIG_HEAD MERGE_HEAD;
                do
                    if [ -e "$dir/$i" ]; then
                        echo $pfx$i;
                    fi;
                done;
                format="refname:short";
                refs="refs/tags refs/heads refs/remotes"
            ;;
        esac;
        git --git-dir="$dir" for-each-ref --format="$pfx%($format)" $refs;
        if [ -n "$track" ]; then
            local ref entry;
            git --git-dir="$dir" for-each-ref --shell --format="ref=%(refname:short)" "refs/remotes/" | while read -r entry; do
                eval "$entry";
                ref="${ref#*/}";
                if [[ "$ref" == "$cur"* ]]; then
                    echo "$ref";
                fi;
            done | sort | uniq -u;
        fi;
        return;
    fi;
    case "$cur" in 
        refs | refs/*)
            git ls-remote "$dir" "$cur*" 2> /dev/null | while read -r hash i; do
                case "$i" in 
                    *^{})

                    ;;
                    *)
                        echo "$i"
                    ;;
                esac;
            done
        ;;
        *)
            echo "HEAD";
            git for-each-ref --format="%(refname:short)" -- "refs/remotes/$dir/" 2> /dev/null | sed -e "s#^$dir/##"
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then __git_refs "$@"; fi
