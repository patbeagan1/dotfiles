__sdkman_update_broadcast () 
{ 
    local broadcast_live_id broadcast_id_file broadcast_text_file broadcast_old_id;
    broadcast_live_id="$1";
    broadcast_id_file="${SDKMAN_DIR}/var/broadcast_id";
    broadcast_text_file="${SDKMAN_DIR}/var/broadcast";
    broadcast_old_id="";
    if [[ -f "$broadcast_id_file" ]]; then
        broadcast_old_id=$(cat "$broadcast_id_file");
    fi;
    if [[ -f "$broadcast_text_file" ]]; then
        BROADCAST_OLD_TEXT=$(cat "$broadcast_text_file");
    fi;
    if [[ "$SDKMAN_AVAILABLE" == "true" && "$broadcast_live_id" != "$broadcast_old_id" && "$COMMAND" != "selfupdate" && "$COMMAND" != "flush" ]]; then
        mkdir -p "${SDKMAN_DIR}/var";
        echo "$broadcast_live_id" > "$broadcast_id_file";
        BROADCAST_LIVE_TEXT=$(__sdkman_secure_curl "${SDKMAN_CURRENT_API}/broadcast/latest");
        echo "$BROADCAST_LIVE_TEXT" > "$broadcast_text_file";
        if [[ "$COMMAND" != "broadcast" ]]; then
            __sdkman_echo_cyan "$BROADCAST_LIVE_TEXT";
        fi;
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_update_broadcast "$@"; fi
