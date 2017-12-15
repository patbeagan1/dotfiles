__sdk_uninstall () 
{ 
    local candidate version current;
    candidate="$1";
    version="$2";
    __sdkman_check_candidate_present "$candidate" || return 1;
    __sdkman_check_version_present "$version" || return 1;
    current=$(readlink "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s_${SDKMAN_CANDIDATES_DIR}/${candidate}/__g");
    if [[ -h "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" && "$version" == "$current" ]]; then
        echo "";
        __sdkman_echo_green "Unselecting ${candidate} ${version}...";
        unlink "${SDKMAN_CANDIDATES_DIR}/${candidate}/current";
    fi;
    echo "";
    if [ -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]; then
        __sdkman_echo_green "Uninstalling ${candidate} ${version}...";
        rm -rf "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}";
    else
        __sdkman_echo_red "${candidate} ${version} is not installed.";
    fi
}
if [[ $0 != "-bash" ]]; then __sdk_uninstall "$@"; fi
