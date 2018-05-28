__sdkman_echo_yellow () 
{ 
    __sdkman_echo "33m" "$1"
}
if [[ $0 != "-bash" ]]; then __sdkman_echo_yellow "$@"; fi
