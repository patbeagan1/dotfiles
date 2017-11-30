__sdk_list () 
{ 
    local candidate="$1";
    if [[ -z "$candidate" ]]; then
        __sdkman_list_candidates;
    else
        __sdkman_list_versions "$candidate";
    fi
}
if [[ $0 != "-bash" ]]; then __sdk_list "$@"; fi
