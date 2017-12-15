__sdkman_determine_upgradable_version () 
{ 
    local candidate local_versions remote_default_version;
    candidate="$1";
    local_versions="$(echo $(find "${SDKMAN_CANDIDATES_DIR}/${candidate}" -maxdepth 1 -mindepth 1 -type d -exec basename '{}' \; 2>/dev/null) | sed -e "s/ /, /g" )";
    if [ ${#local_versions} -eq 0 ]; then
        return 1;
    fi;
    remote_default_version="$(__sdkman_secure_curl "${SDKMAN_CURRENT_API}/candidates/default/${candidate}")";
    if [ -z "$remote_default_version" ]; then
        return 2;
    fi;
    if [ ! -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${remote_default_version}" ]; then
        __sdkman_echo_yellow "${candidate} (${local_versions} < ${remote_default_version})";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_determine_upgradable_version "$@"; fi
