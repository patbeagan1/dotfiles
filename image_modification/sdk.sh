sdk () 
{ 
    COMMAND="$1";
    QUALIFIER="$2";
    case "$COMMAND" in 
        l)
            COMMAND="list"
        ;;
        ls)
            COMMAND="list"
        ;;
        h)
            COMMAND="help"
        ;;
        v)
            COMMAND="version"
        ;;
        u)
            COMMAND="use"
        ;;
        i)
            COMMAND="install"
        ;;
        rm)
            COMMAND="uninstall"
        ;;
        c)
            COMMAND="current"
        ;;
        ug)
            COMMAND="upgrade"
        ;;
        outdated)
            COMMAND="upgrade"
        ;;
        o)
            COMMAND="upgrade"
        ;;
        d)
            COMMAND="default"
        ;;
        b)
            COMMAND="broadcast"
        ;;
    esac;
    mkdir -p "$SDKMAN_DIR";
    SDKMAN_AVAILABLE="true";
    if [ -z "$SDKMAN_OFFLINE_MODE" ]; then
        SDKMAN_OFFLINE_MODE="false";
    fi;
    __sdkman_update_broadcast_and_service_availability;
    if [ -f "${SDKMAN_DIR}/etc/config" ]; then
        source "${SDKMAN_DIR}/etc/config";
    fi;
    if [[ -z "$COMMAND" ]]; then
        __sdk_help;
        return 1;
    fi;
    CMD_FOUND="";
    CMD_TARGET="${SDKMAN_DIR}/src/sdkman-${COMMAND}.sh";
    if [[ -f "$CMD_TARGET" ]]; then
        CMD_FOUND="$CMD_TARGET";
    fi;
    CMD_TARGET="${SDKMAN_DIR}/ext/sdkman-${COMMAND}.sh";
    if [[ -f "$CMD_TARGET" ]]; then
        CMD_FOUND="$CMD_TARGET";
    fi;
    if [[ -z "$CMD_FOUND" ]]; then
        echo "Invalid command: $COMMAND";
        __sdk_help;
    fi;
    local sdkman_valid_candidate=$(echo ${SDKMAN_CANDIDATES[@]} | grep -w "$QUALIFIER");
    if [[ -n "$QUALIFIER" && "$COMMAND" != "offline" && "$COMMAND" != "flush" && "$COMMAND" != "selfupdate" && -z "$sdkman_valid_candidate" ]]; then
        echo "";
        __sdkman_echo_red "Stop! $QUALIFIER is not a valid candidate.";
        return 1;
    fi;
    if [[ "$COMMAND" == "offline" && -n "$QUALIFIER" && -z $(echo "enable disable" | grep -w "$QUALIFIER") ]]; then
        echo "";
        __sdkman_echo_red "Stop! $QUALIFIER is not a valid offline mode.";
    fi;
    CONVERTED_CMD_NAME=$(echo "$COMMAND" | tr '-' '_');
    if [ -n "$CMD_FOUND" ]; then
        __sdk_"$CONVERTED_CMD_NAME" "$QUALIFIER" "$3" "$4";
    fi;
    if [[ "$COMMAND" != "selfupdate" ]]; then
        __sdkman_auto_update "$SDKMAN_REMOTE_VERSION" "$SDKMAN_VERSION";
    fi
}

if [[ "$1" = "-e" ]]; then shift; sdk "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
