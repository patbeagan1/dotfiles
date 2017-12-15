__sdk_install () 
{ 
    local candidate version folder;
    candidate="$1";
    version="$2";
    folder="$3";
    __sdkman_check_candidate_present "$candidate" || return 1;
    __sdkman_determine_version "$candidate" "$version" "$folder" || return 1;
    if [[ -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" || -h "${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" ]]; then
        echo "";
        __sdkman_echo_red "Stop! ${candidate} ${VERSION} is already installed.";
        return 0;
    fi;
    if [[ ${VERSION_VALID} == 'valid' ]]; then
        __sdkman_determine_current_version "$candidate";
        __sdkman_install_candidate_version "$candidate" "$VERSION" || return 1;
        if [[ "$sdkman_auto_answer" != 'true' && "$auto_answer_upgrade" != 'true' && -n "$CURRENT" ]]; then
            __sdkman_echo_confirm "Do you want ${candidate} ${VERSION} to be set as default? (Y/n): ";
            read USE;
        fi;
        if [[ -z "$USE" || "$USE" == "y" || "$USE" == "Y" ]]; then
            echo "";
            __sdkman_echo_green "Setting ${candidate} ${VERSION} as default.";
            __sdkman_link_candidate_version "$candidate" "$VERSION";
            __sdkman_add_to_path "$candidate";
        fi;
        return 0;
    else
        if [[ "$VERSION_VALID" == 'invalid' && -n "$folder" ]]; then
            __sdkman_install_local_version "$candidate" "$VERSION" "$folder" || return 1;
        else
            echo "";
            __sdkman_echo_red "Stop! $1 is not a valid ${candidate} version.";
            return 1;
        fi;
    fi
}
if [[ $0 != "-bash" ]]; then __sdk_install "$@"; fi
