__sdkman_install_candidate_version () 
{ 
    local candidate version;
    candidate="$1";
    version="$2";
    __sdkman_download "$candidate" "$version" || return 1;
    __sdkman_echo_green "Installing: ${candidate} ${version}";
    mkdir -p "${SDKMAN_CANDIDATES_DIR}/${candidate}";
    rm -rf "${SDKMAN_DIR}/tmp/out";
    unzip -oq "${SDKMAN_DIR}/archives/${candidate}-${version}.zip" -d "${SDKMAN_DIR}/tmp/out";
    mv "$SDKMAN_DIR"/tmp/out/* "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}";
    __sdkman_echo_green "Done installing!";
    echo ""
}
if [[ $0 != "-bash" ]]; then __sdkman_install_candidate_version "$@"; fi
