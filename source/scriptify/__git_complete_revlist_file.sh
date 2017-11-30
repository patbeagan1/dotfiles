__git_complete_revlist_file () 
{ 
    local pfx ls ref cur_="$cur";
    case "$cur_" in 
        *..?*:*)
            return
        ;;
        ?*:*)
            ref="${cur_%%:*}";
            cur_="${cur_#*:}";
            case "$cur_" in 
                ?*/*)
                    pfx="${cur_%/*}";
                    cur_="${cur_##*/}";
                    ls="$ref:$pfx";
                    pfx="$pfx/"
                ;;
                *)
                    ls="$ref"
                ;;
            esac;
            case "$COMP_WORDBREAKS" in 
                *:*)
                    : great
                ;;
                *)
                    pfx="$ref:$pfx"
                ;;
            esac;
            __gitcomp_nl "$(git --git-dir="$(__gitdir)" ls-tree "$ls" 2>/dev/null 				| sed '/^100... blob /{
				           s,^.*	,,
				           s,$, ,
				       }
				       /^120000 blob /{
				           s,^.*	,,
				           s,$, ,
				       }
				       /^040000 tree /{
				           s,^.*	,,
				           s,$,/,
				       }
				       s/^.*	//')" "$pfx" "$cur_" ""
        ;;
        *...*)
            pfx="${cur_%...*}...";
            cur_="${cur_#*...}";
            __gitcomp_nl "$(__git_refs)" "$pfx" "$cur_"
        ;;
        *..*)
            pfx="${cur_%..*}..";
            cur_="${cur_#*..}";
            __gitcomp_nl "$(__git_refs)" "$pfx" "$cur_"
        ;;
        *)
            __gitcomp_nl "$(__git_refs)"
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then __git_complete_revlist_file "$@"; fi
