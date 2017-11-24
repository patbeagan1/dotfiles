__sdkman_display_offline_warning () 
{ 
    local broadcast_id="$1";
    if [[ -z "$broadcast_id" && "$COMMAND" != "offline" && "$SDKMAN_OFFLINE_MODE" != "true" ]]; then
        __sdkman_echo_red "==== INTERNET NOT REACHABLE! ===================================================";
        __sdkman_echo_red "";
        __sdkman_echo_red " Some functionality is disabled or only partially available.";
        __sdkman_echo_red " If this persists, please enable the offline mode:";
        __sdkman_echo_red "";
        __sdkman_echo_red "   $ sdk offline";
        __sdkman_echo_red "";
        __sdkman_echo_red "================================================================================";
        echo "";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_display_offline_warning "$@"; fi
