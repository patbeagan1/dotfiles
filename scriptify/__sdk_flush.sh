__sdk_flush () 
{ 
    local qualifier="$1";
    case "$qualifier" in 
        candidates)
            if [[ -f "${SDKMAN_DIR}/var/candidates" ]]; then
                rm "${SDKMAN_DIR}/var/candidates";
                __sdkman_echo_green "Candidates have been flushed.";
            else
                __sdkman_echo_no_colour "No candidate list found so not flushed.";
            fi
        ;;
        broadcast)
            if [[ -f "${SDKMAN_DIR}/var/broadcast" ]]; then
                rm "${SDKMAN_DIR}/var/broadcast";
                __sdkman_echo_green "Broadcast has been flushed.";
            else
                __sdkman_echo_no_colour "No prior broadcast found so not flushed.";
            fi
        ;;
        version)
            if [[ -f "${SDKMAN_DIR}/var/version" ]]; then
                rm "${SDKMAN_DIR}/var/version";
                __sdkman_echo_green "Version file has been flushed.";
            else
                __sdkman_echo_no_colour "No prior Remote Version found so not flushed.";
            fi
        ;;
        archives)
            __sdkman_cleanup_folder "archives"
        ;;
        temp)
            __sdkman_cleanup_folder "tmp"
        ;;
        tmp)
            __sdkman_cleanup_folder "tmp"
        ;;
        *)
            __sdkman_echo_red "Stop! Please specify what you want to flush."
        ;;
    esac
}
if [[ $0 != "-bash" ]]; then __sdk_flush "$@"; fi
