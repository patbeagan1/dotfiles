__sdkman_echo_debug () 
{ 
    if [[ "$sdkman_debug_mode" == 'true' ]]; then
        echo "$1";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_echo_debug "$@"; fi
