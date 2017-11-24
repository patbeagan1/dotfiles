__sdkman_secure_curl_with_timeouts () 
{ 
    if [[ "${sdkman_insecure_ssl}" == 'true' ]]; then
        curl --insecure --silent --location --connect-timeout ${sdkman_curl_connect_timeout} --max-time ${sdkman_curl_max_time} "$1";
    else
        curl --silent --location --connect-timeout ${sdkman_curl_connect_timeout} --max-time ${sdkman_curl_max_time} "$1";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_secure_curl_with_timeouts "$@"; fi
