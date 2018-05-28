__sdkman_echo_green () 
{ 
    __sdkman_echo "32m" "$1"
}
if [[ $0 != "-bash" ]]; then __sdkman_echo_green "$@"; fi
