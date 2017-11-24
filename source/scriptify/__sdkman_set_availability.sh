__sdkman_set_availability () 
{ 
    local broadcast_id="$1";
    local detect_html="$(echo "$broadcast_id" | tr '[:upper:]' '[:lower:]' | grep 'html')";
    if [[ -z "$broadcast_id" ]]; then
        SDKMAN_AVAILABLE="false";
        __sdkman_display_offline_warning "$broadcast_id";
    else
        if [[ -n "$detect_html" ]]; then
            SDKMAN_AVAILABLE="false";
            __sdkman_display_proxy_warning;
        else
            SDKMAN_AVAILABLE="true";
        fi;
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_set_availability "$@"; fi
