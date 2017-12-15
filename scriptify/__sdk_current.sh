__sdk_current () 
{ 
    local candidate="$1";
    echo "";
    if [ -n "$candidate" ]; then
        __sdkman_determine_current_version "$candidate";
        if [ -n "$CURRENT" ]; then
            __sdkman_echo_no_colour "Using ${candidate} version ${CURRENT}";
        else
            __sdkman_echo_red "Not using any version of ${candidate}";
        fi;
    else
        local installed_count=0;
        for ((i=0; i <= ${#SDKMAN_CANDIDATES[*]}; i++ ))
        do
            if [[ -n ${SDKMAN_CANDIDATES[${i}]} ]]; then
                __sdkman_determine_current_version "${SDKMAN_CANDIDATES[${i}]}";
                if [ -n "$CURRENT" ]; then
                    if [ ${installed_count} -eq 0 ]; then
                        __sdkman_echo_no_colour 'Using:';
                        echo "";
                    fi;
                    __sdkman_echo_no_colour "${SDKMAN_CANDIDATES[${i}]}: ${CURRENT}";
                    (( installed_count += 1 ));
                fi;
            fi;
        done;
        if [ ${installed_count} -eq 0 ]; then
            __sdkman_echo_no_colour 'No candidates are in use';
        fi;
    fi
}
if [[ $0 != "-bash" ]]; then __sdk_current "$@"; fi
