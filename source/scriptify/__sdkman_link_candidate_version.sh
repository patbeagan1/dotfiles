__sdkman_link_candidate_version () 
{ 
    local candidate version;
    candidate="$1";
    version="$2";
    if [[ -h "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" || -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" ]]; then
        rm -f "${SDKMAN_CANDIDATES_DIR}/${candidate}/current";
    fi;
    ln -s "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" "${SDKMAN_CANDIDATES_DIR}/${candidate}/current"
}
if [[ $0 != "-bash" ]]; then __sdkman_link_candidate_version "$@"; fi
