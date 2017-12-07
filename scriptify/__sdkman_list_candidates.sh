__sdkman_list_candidates () 
{ 
    if [[ "$SDKMAN_AVAILABLE" == "false" ]]; then
        __sdkman_echo_red "This command is not available while offline.";
    else
        __sdkman_page echo "$(__sdkman_secure_curl "${SDKMAN_CURRENT_API}/candidates/list")";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_list_candidates "$@"; fi
