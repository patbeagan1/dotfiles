__sdkman_check_version_present () 
{ 
    local version="$1";
    if [ -z "$version" ]; then
        echo "";
        __sdkman_echo_red "No candidate version provided.";
        __sdk_help;
        return 1;
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_check_version_present "$@"; fi
