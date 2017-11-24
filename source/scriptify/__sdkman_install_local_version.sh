__sdkman_install_local_version () 
{ 
    local candidate version folder;
    candidate="$1";
    version="$2";
    folder="$3";
    mkdir -p "${SDKMAN_CANDIDATES_DIR}/${candidate}";
    if [[ "$folder" != /* ]]; then
        folder="$(pwd)/$folder";
    fi;
    if [[ -d "$folder" ]]; then
        __sdkman_echo_green "Linking ${candidate} ${version} to ${folder}";
        ln -s "$folder" "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}";
        __sdkman_echo_green "Done installing!";
    else
        __sdkman_echo_red "Invalid path! Refusing to link ${candidate} ${version} to ${folder}.";
    fi;
    echo ""
}
if [[ $0 != "-bash" ]]; then __sdkman_install_local_version "$@"; fi
