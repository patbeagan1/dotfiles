__sdkman_echo_no_colour () 
{ 
    echo "$1"
}
if [[ $0 != "-bash" ]]; then __sdkman_echo_no_colour "$@"; fi
