__sdk_upgrade () 
{ 
    local all candidates candidate upgradable installed_count upgradable_count upgradable_candidates;
    if [ -n "$1" ]; then
        all=false;
        candidates=$1;
    else
        all=true;
        if [[ "$zsh_shell" == 'true' ]]; then
            candidates=(${SDKMAN_CANDIDATES[@]});
        else
            candidates=${SDKMAN_CANDIDATES[@]};
        fi;
    fi;
    installed_count=0;
    upgradable_count=0;
    echo "";
    for candidate in ${candidates};
    do
        upgradable="$(__sdkman_determine_upgradable_version "$candidate")";
        case $? in 
            1)
                $all || __sdkman_echo_red "Not using any version of ${candidate}"
            ;;
            2)
                echo "";
                __sdkman_echo_red "Stop! Could not get remote version of ${candidate}";
                return 1
            ;;
            *)
                if [ -n "$upgradable" ]; then
                    [ ${upgradable_count} -eq 0 ] && __sdkman_echo_no_colour "Upgrade:";
                    __sdkman_echo_no_colour "$upgradable";
                    (( upgradable_count += 1 ));
                    upgradable_candidates=(${upgradable_candidates[@]} $candidate);
                fi;
                (( installed_count += 1 ))
            ;;
        esac;
    done;
    if $all; then
        if [ ${installed_count} -eq 0 ]; then
            __sdkman_echo_no_colour 'No candidates are in use';
        else
            if [ ${upgradable_count} -eq 0 ]; then
                __sdkman_echo_no_colour "All candidates are up-to-date";
            fi;
        fi;
    else
        if [ ${upgradable_count} -eq 0 ]; then
            __sdkman_echo_no_colour "${candidate} is up-to-date";
        fi;
    fi;
    if [ ${upgradable_count} -gt 0 ]; then
        echo "";
        __sdkman_echo_confirm "Upgrade candidate(s) and set latest version(s) as default? (Y/n): ";
        read UPGRADE_ALL;
        export auto_answer_upgrade='true';
        if [[ -z "$UPGRADE_ALL" || "$UPGRADE_ALL" == "y" || "$UPGRADE_ALL" == "Y" ]]; then
            for ((i=0; i <= ${#upgradable_candidates[*]}; i++ ))
            do
                upgradable_candidate="${upgradable_candidates[${i}]}";
                if [[ -n "$upgradable_candidate" ]]; then
                    __sdk_install $upgradable_candidate;
                fi;
            done;
        fi;
        unset auto_answer_upgrade;
    fi
}
if [[ $0 != "-bash" ]]; then __sdk_upgrade "$@"; fi
