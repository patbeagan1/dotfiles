__sdkman_auto_update () 
{ 
    local remote_version version delay_upgrade;
    remote_version="$1";
    version="$2";
    delay_upgrade="${SDKMAN_DIR}/var/delay_upgrade";
    if [[ -n "$(find "$delay_upgrade" -mtime +1)" && "$remote_version" != "$version" ]]; then
        echo "";
        echo "";
        __sdkman_echo_yellow "ATTENTION: A new version of SDKMAN is available...";
        echo "";
        __sdkman_echo_no_colour "The current version is $remote_version, but you have $version.";
        echo "";
        if [[ "$sdkman_auto_selfupdate" != "true" ]]; then
            __sdkman_echo_confirm "Would you like to upgrade now? (Y/n)";
            read upgrade;
        fi;
        if [[ -z "$upgrade" ]]; then
            upgrade="Y";
        fi;
        if [[ "$upgrade" == "Y" || "$upgrade" == "y" ]]; then
            __sdk_selfupdate;
            unset upgrade;
        else
            __sdkman_echo_no_colour "Not upgrading today...";
        fi;
        touch "$delay_upgrade";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_auto_update "$@"; fi
