__sdkman_offline_list () 
{ 
    local candidate versions_csv;
    candidate="$1";
    versions_csv="$2";
    __sdkman_echo_no_colour "--------------------------------------------------------------------------------";
    __sdkman_echo_yellow "Offline: only showing installed ${candidate} versions";
    __sdkman_echo_no_colour "--------------------------------------------------------------------------------";
    local versions=($(echo ${versions_csv//,/ }));
    for ((i=${#versions} - 1 ; i >= 0  ; i-- ))
    do
        if [[ -n "${versions[${i}]}" ]]; then
            if [[ "${versions[${i}]}" == "$CURRENT" ]]; then
                __sdkman_echo_no_colour " > ${versions[${i}]}";
            else
                __sdkman_echo_no_colour " * ${versions[${i}]}";
            fi;
        fi;
    done;
    if [[ -z "${versions[@]}" ]]; then
        __sdkman_echo_yellow "   None installed!";
    fi;
    __sdkman_echo_no_colour "--------------------------------------------------------------------------------";
    __sdkman_echo_no_colour "* - installed                                                                   ";
    __sdkman_echo_no_colour "> - currently in use                                                            ";
    __sdkman_echo_no_colour "--------------------------------------------------------------------------------"
}
if [[ $0 != "-bash" ]]; then __sdkman_offline_list "$@"; fi
