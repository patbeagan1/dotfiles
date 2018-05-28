__sdkman_path_contains () 
{ 
    local candidate exists;
    candidate="$1";
    exists="$(echo "$PATH" | grep "$candidate")";
    if [[ -n "$exists" ]]; then
        echo 'true';
    else
        echo 'false';
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_path_contains "$@"; fi
