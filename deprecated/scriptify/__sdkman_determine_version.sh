__sdkman_determine_version () 
{ 
    local candidate version folder;
    candidate="$1";
    version="$2";
    folder="$3";
    if [[ "$SDKMAN_AVAILABLE" == "false" && -n "$version" && -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
        VERSION="$version";
    else
        if [[ "$SDKMAN_AVAILABLE" == "false" && -z "$version" && -L "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" ]]; then
            VERSION=$(readlink "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${SDKMAN_CANDIDATES_DIR}/${candidate}/!!g");
        else
            if [[ "$SDKMAN_AVAILABLE" == "false" && -n "$version" ]]; then
                __sdkman_echo_red "Stop! ${candidate} ${version} is not available while offline.";
                return 1;
            else
                if [[ "$SDKMAN_AVAILABLE" == "false" && -z "$version" ]]; then
                    __sdkman_echo_red "This command is not available while offline.";
                    return 1;
                else
                    if [[ -z "$version" ]]; then
                        version=$(__sdkman_secure_curl "${SDKMAN_CURRENT_API}/candidates/default/${candidate}");
                    fi;
                    local validation_url="${SDKMAN_CURRENT_API}/candidates/validate/${candidate}/${version}/$(echo $SDKMAN_PLATFORM | tr '[:upper:]' '[:lower:]')";
                    VERSION_VALID=$(__sdkman_secure_curl "$validation_url");
                    __sdkman_echo_debug "Validate $candidate $version for $SDKMAN_PLATFORM: $VERSION_VALID";
                    __sdkman_echo_debug "Validation URL: $validation_url";
                    if [[ "$VERSION_VALID" == 'valid' || "$VERSION_VALID" == 'invalid' && -n "$folder" ]]; then
                        VERSION="$version";
                    else
                        if [[ "$VERSION_VALID" == 'invalid' && -h "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
                            VERSION="$version";
                        else
                            if [[ "$VERSION_VALID" == 'invalid' && -d "${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}" ]]; then
                                VERSION="$version";
                            else
                                echo "";
                                __sdkman_echo_red "Stop! $candidate $version is not available. Possible causes:";
                                __sdkman_echo_red " * $version is an invalid version";
                                __sdkman_echo_red " * $candidate binaries are incompatible with $SDKMAN_PLATFORM";
                                return 1;
                            fi;
                        fi;
                    fi;
                fi;
            fi;
        fi;
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_determine_version "$@"; fi
