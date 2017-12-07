__sdkman_validate_zip () 
{ 
    local zip_archive zip_ok;
    zip_archive="$1";
    zip_ok=$(unzip -t "$zip_archive" | grep 'No errors detected in compressed data');
    if [ -z "$zip_ok" ]; then
        rm "$zip_archive";
        echo "";
        __sdkman_echo_red "Stop! The archive was corrupt and has been removed! Please try installing again.";
        return 1;
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_validate_zip "$@"; fi
