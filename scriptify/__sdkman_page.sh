__sdkman_page () 
{ 
    if [[ -n "$PAGER" ]]; then
        "$@" | eval $PAGER;
    else
        if command -v less >&/dev/null; then
            "$@" | less;
        else
            "$@";
        fi;
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_page "$@"; fi
