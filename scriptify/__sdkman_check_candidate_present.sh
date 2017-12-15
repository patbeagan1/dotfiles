__sdkman_check_candidate_present () 
{ 
    local candidate="$1";
    if [ -z "$candidate" ]; then
        echo "";
        __sdkman_echo_red "No candidate provided.";
        __sdk_help;
        return 1;
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_check_candidate_present "$@"; fi
