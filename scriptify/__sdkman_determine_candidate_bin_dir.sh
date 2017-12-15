__sdkman_determine_candidate_bin_dir () 
{ 
    local candidate_dir="$1";
    if [[ -d "${candidate_dir}/bin" ]]; then
        echo "${candidate_dir}/bin";
    else
        echo "$candidate_dir";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_determine_candidate_bin_dir "$@"; fi
