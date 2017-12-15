__sdkman_secure_curl () 
{ 
    if [[ "${sdkman_insecure_ssl}" == 'true' ]]; then
        curl --insecure --silent --location "$1";
    else
        curl --silent --location "$1";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_secure_curl "$@"; fi
