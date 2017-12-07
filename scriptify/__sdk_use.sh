__sdk_use () 
{ 
    local candidate version install;
    candidate="$1";
    version="$2";
    __sdkman_check_candidate_present "$candidate" || return 1;
    __sdkman_determine_version "$candidate" "$version" || return 1;
    if [[ ! -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}" ]]; then
        echo "";
        __sdkman_echo_red "Stop! ${candidate} ${VERSION} is not installed.";
        if [[ "$sdkman_auto_answer" != 'true' ]]; then
            echo "";
            __sdkman_echo_confirm "Do you want to install it now? (Y/n): ";
            read install;
        fi;
        if [[ -z "$install" || "$install" == "y" || "$install" == "Y" ]]; then
            __sdkman_install_candidate_version "$candidate" "$VERSION";
            __sdkman_add_to_path "$candidate";
        else
            return 1;
        fi;
    fi;
    __sdkman_set_candidate_home "$candidate" "$VERSION";
    if [[ "$solaris" == true ]]; then
        export PATH=$(echo $PATH | gsed -r "s!${SDKMAN_CANDIDATES_DIR}/${candidate}/([^/]+)!${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}!g");
    else
        if [[ "$darwin" == true ]]; then
            export PATH=$(echo $PATH | sed -E "s!${SDKMAN_CANDIDATES_DIR}/${candidate}/([^/]+)!${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}!g");
        else
            export PATH=$(echo "$PATH" | sed -r "s!${SDKMAN_CANDIDATES_DIR}/${candidate}/([^/]+)!${SDKMAN_CANDIDATES_DIR}/${candidate}/${VERSION}!g");
        fi;
    fi;
    if [[ ! ( -h "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" || -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" ) ]]; then
        __sdkman_echo_green "Setting ${candidate} version ${VERSION} as default.";
        __sdkman_link_candidate_version "$candidate" "$VERSION";
    fi;
    echo "";
    __sdkman_echo_green "Using ${candidate} version ${VERSION} in this shell."
}
if [[ $0 != "-bash" ]]; then __sdk_use "$@"; fi
