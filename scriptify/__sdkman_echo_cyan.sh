__sdkman_echo_cyan () 
{ 
    __sdkman_echo "36m" "$1"
}
if [[ $0 != "-bash" ]]; then __sdkman_echo_cyan "$@"; fi
