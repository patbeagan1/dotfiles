__sdk_version () 
{ 
    echo "";
    __sdkman_echo_yellow "SDKMAN ${SDKMAN_VERSION}"
}
if [[ $0 != "-bash" ]]; then __sdk_version "$@"; fi
