__sdkman_determine_broadcast_id () 
{ 
    if [[ "$SDKMAN_OFFLINE_MODE" == "true" || "$COMMAND" == "offline" && "$QUALIFIER" == "enable" ]]; then
        echo "";
    else
        echo $(__sdkman_secure_curl_with_timeouts "${SDKMAN_CURRENT_API}/broadcast/latest/id");
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_determine_broadcast_id "$@"; fi
