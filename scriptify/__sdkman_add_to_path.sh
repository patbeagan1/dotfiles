__sdkman_add_to_path () 
{ 
    local candidate present;
    candidate="$1";
    present=$(__sdkman_path_contains "$candidate");
    if [[ "$present" == 'false' ]]; then
        PATH="$SDKMAN_CANDIDATES_DIR/$candidate/current/bin:$PATH";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_add_to_path "$@"; fi
