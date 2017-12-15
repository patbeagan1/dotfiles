__sdkman_echo_confirm () 
{ 
    if [[ "$sdkman_colour_enable" == 'false' ]]; then
        echo -n "$1";
    else
        echo -e -n "\033[1;33m$1\033[0m";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_echo_confirm "$@"; fi
