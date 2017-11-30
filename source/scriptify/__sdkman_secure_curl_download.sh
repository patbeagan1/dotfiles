__sdkman_secure_curl_download () 
{ 
    local curl_params="--progress-bar --location";
    if [[ "${sdkman_insecure_ssl}" == 'true' ]]; then
        curl_params="$curl_params --insecure";
    fi;
    local cookie_file="${SDKMAN_DIR}/var/cookie";
    if [[ -f "$cookie_file" ]]; then
        local cookie=$(cat "$cookie_file");
        curl_params="$curl_params --cookie $cookie";
    fi;
    if [[ "$zsh_shell" == 'true' ]]; then
        curl ${=curl_params} "$1";
    else
        curl ${curl_params} "$1";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_secure_curl_download "$@"; fi
