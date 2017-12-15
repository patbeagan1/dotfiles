__sdkman_display_proxy_warning () 
{ 
    __sdkman_echo_red "==== PROXY DETECTED! ===========================================================";
    __sdkman_echo_red "Please ensure you have open internet access to continue.";
    __sdkman_echo_red "================================================================================";
    echo ""
}
if [[ $0 != "-bash" ]]; then __sdkman_display_proxy_warning "$@"; fi
