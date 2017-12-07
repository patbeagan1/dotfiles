__sdk_default () 
{ 
    local candidate version;
    candidate="$1";
    version="$2";
    __sdkman_check_candidate_present "$candidate" || return 1;
    __sdkman_determine_version "$candidate" "$version" || return 1;
    if [ ! -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" ]; then
        echo "";
        __sdkman_echo_red "Stop! ${candidate} ${VERSION} is not installed.";
        return 1;
    fi;
    __sdkman_link_candidate_version "$candidate" "$VERSION";
    echo "";
    __sdkman_echo_green "Default ${candidate} version set to ${VERSION}"
}
if [[ $0 != "-bash" ]]; then __sdk_default "$@"; fi
