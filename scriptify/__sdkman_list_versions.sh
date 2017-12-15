__sdkman_list_versions () 
{ 
    local candidate versions_csv;
    candidate="$1";
    versions_csv="$(__sdkman_build_version_csv "$candidate")";
    __sdkman_determine_current_version "$candidate";
    if [[ "$SDKMAN_AVAILABLE" == "false" ]]; then
        __sdkman_offline_list "$candidate" "$versions_csv";
    else
        __sdkman_echo_no_colour "$(__sdkman_secure_curl "${SDKMAN_LEGACY_API}/candidates/${candidate}/list?platform=${SDKMAN_PLATFORM}&current=${CURRENT}&installed=${versions_csv}")";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_list_versions "$@"; fi
