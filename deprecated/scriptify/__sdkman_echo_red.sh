__sdkman_echo_red () 
{ 
    __sdkman_echo "31m" "$1"
}
if [[ $0 != "-bash" ]]; then __sdkman_echo_red "$@"; fi
