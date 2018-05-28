__sdkman_download () 
{ 
    local candidate version archives_folder;
    candidate="$1";
    version="$2";
    archives_folder="${SDKMAN_DIR}/archives";
    if [ ! -f "${archives_folder}/${candidate}-${version}.zip" ]; then
        local platform_parameter="$(echo $SDKMAN_PLATFORM | tr '[:upper:]' '[:lower:]')";
        local download_url="${SDKMAN_CURRENT_API}/broker/download/${candidate}/${version}/${platform_parameter}";
        local base_name="$(head /dev/urandom | env LC_CTYPE=C tr -dc 'a-zA-Z0-9' | fold -w 32 | head -n 1)";
        local zip_archive_target="${SDKMAN_DIR}/archives/${candidate}-${version}.zip";
        local pre_installation_hook="${SDKMAN_DIR}/tmp/hook_pre_${candidate}_${version}.sh";
        __sdkman_echo_debug "Get pre-installation hook: ${SDKMAN_CURRENT_API}/hooks/pre/${candidate}/${version}/${platform_parameter}";
        __sdkman_secure_curl "${SDKMAN_CURRENT_API}/hooks/pre/${candidate}/${version}/${platform_parameter}" > "$pre_installation_hook";
        __sdkman_echo_debug "Copy remote pre-installation hook: $pre_installation_hook";
        source "$pre_installation_hook";
        __sdkman_pre_installation_hook || return 1;
        __sdkman_echo_debug "Completed pre-installation hook...";
        export local binary_input="${SDKMAN_DIR}/tmp/${base_name}.bin";
        export local zip_output="${SDKMAN_DIR}/tmp/$base_name.zip";
        echo "";
        __sdkman_echo_no_colour "Downloading: ${candidate} ${version}";
        echo "";
        __sdkman_echo_no_colour "In progress...";
        echo "";
        __sdkman_secure_curl_download "$download_url" > "$binary_input";
        __sdkman_echo_debug "Downloaded binary to: $binary_input";
        local post_installation_hook="${SDKMAN_DIR}/tmp/hook_post_${candidate}_${version}.sh";
        __sdkman_echo_debug "Get post-installation hook: ${SDKMAN_CURRENT_API}/hooks/post/${candidate}/${version}/${platform_parameter}";
        __sdkman_secure_curl "${SDKMAN_CURRENT_API}/hooks/post/${candidate}/${version}/${platform_parameter}" > "$post_installation_hook";
        __sdkman_echo_debug "Copy remote pre-installation hook: $pre_installation_hook";
        source "$post_installation_hook";
        __sdkman_post_installation_hook || return 1;
        __sdkman_echo_debug "Processed binary as: $zip_output";
        __sdkman_echo_debug "Completed post-installation hook...";
        mv "$zip_output" "$zip_archive_target";
        __sdkman_echo_debug "Moved to archive folder: $zip_archive_target";
    else
        echo "";
        __sdkman_echo_no_colour "Found a previously downloaded ${candidate} ${version} archive. Not downloading it again...";
    fi;
    __sdkman_validate_zip "${archives_folder}/${candidate}-${version}.zip" || return 1;
    echo ""
}
if [[ $0 != "-bash" ]]; then __sdkman_download "$@"; fi
