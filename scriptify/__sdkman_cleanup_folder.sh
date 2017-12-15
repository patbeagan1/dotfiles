__sdkman_cleanup_folder () 
{ 
    local folder="$1";
    sdkman_cleanup_dir="${SDKMAN_DIR}/${folder}";
    sdkman_cleanup_disk_usage=$(du -sh "$sdkman_cleanup_dir");
    sdkman_cleanup_count=$(ls -1 "$sdkman_cleanup_dir" | wc -l);
    rm -rf "${SDKMAN_DIR}/${folder}";
    mkdir "${SDKMAN_DIR}/${folder}";
    __sdkman_echo_green "${sdkman_cleanup_count} archive(s) flushed, freeing ${sdkman_cleanup_disk_usage}."
}
if [[ $0 != "-bash" ]]; then __sdkman_cleanup_folder "$@"; fi
