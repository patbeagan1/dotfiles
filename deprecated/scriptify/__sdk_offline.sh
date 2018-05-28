__sdk_offline () 
{ 
    local mode="$1";
    if [[ -z "$mode" || "$mode" == "enable" ]]; then
        SDKMAN_OFFLINE_MODE="true";
        __sdkman_echo_green "Offline mode enabled.";
    fi;
    if [[ "$mode" == "disable" ]]; then
        SDKMAN_OFFLINE_MODE="false";
        __sdkman_echo_green "Online mode re-enabled!";
    fi
}
if [[ $0 != "-bash" ]]; then __sdk_offline "$@"; fi
