__sdk_broadcast () 
{ 
    if [ "$BROADCAST_OLD_TEXT" ]; then
        __sdkman_echo_cyan "$BROADCAST_OLD_TEXT";
    else
        __sdkman_echo_cyan "$BROADCAST_LIVE_TEXT";
    fi
}
if [[ $0 != "-bash" ]]; then __sdk_broadcast "$@"; fi
