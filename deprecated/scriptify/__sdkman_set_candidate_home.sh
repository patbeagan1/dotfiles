__sdkman_set_candidate_home () 
{ 
    local candidate version upper_candidate;
    candidate="$1";
    version="$2";
    upper_candidate=$(echo "$candidate" | tr '[:lower:]' '[:upper:]');
    export "${upper_candidate}_HOME"="${SDKMAN_CANDIDATES_DIR}/${candidate}/${version}"
}
if [[ $0 != "-bash" ]]; then __sdkman_set_candidate_home "$@"; fi
