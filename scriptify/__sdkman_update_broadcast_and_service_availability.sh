__sdkman_update_broadcast_and_service_availability () 
{ 
    local broadcast_live_id=$(__sdkman_determine_broadcast_id);
    __sdkman_set_availability "$broadcast_live_id";
    __sdkman_update_broadcast "$broadcast_live_id"
}
if [[ $0 != "-bash" ]]; then __sdkman_update_broadcast_and_service_availability "$@"; fi
