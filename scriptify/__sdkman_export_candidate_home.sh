__sdkman_export_candidate_home () 
{ 
    local candidate_name="$1";
    local candidate_dir="$2";
    local candidate_home_var="$(echo ${candidate_name} | tr '[:lower:]' '[:upper:]')_HOME";
    export $(echo "$candidate_home_var")="$candidate_dir"
}
if [[ $0 != "-bash" ]]; then __sdkman_export_candidate_home "$@"; fi
