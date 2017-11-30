__sdk_selfupdate () 
{ 
    local force_selfupdate;
    force_selfupdate="$1";
    if [[ "$SDKMAN_AVAILABLE" == "false" ]]; then
        echo "This command is not available while offline.";
    else
        if [[ "$SDKMAN_REMOTE_VERSION" == "$SDKMAN_VERSION" && "$force_selfupdate" != "force" ]]; then
            echo "No update available at this time.";
        else
            export sdkman_debug_mode;
            export sdkman_beta_channel;
            __sdkman_secure_curl "${SDKMAN_CURRENT_API}/selfupdate?beta=${sdkman_beta_channel}" | bash;
        fi;
    fi;
    unset SDKMAN_FORCE_SELFUPDATE
}
if [[ $0 != "-bash" ]]; then __sdk_selfupdate "$@"; fi
