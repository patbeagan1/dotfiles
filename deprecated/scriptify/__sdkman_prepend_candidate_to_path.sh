__sdkman_prepend_candidate_to_path () 
{ 
    local candidate_dir candidate_bin_dir;
    candidate_dir="$1";
    candidate_bin_dir=$(__sdkman_determine_candidate_bin_dir "$candidate_dir");
    echo "$PATH" | grep --color=auto -q "$candidate_dir" || PATH="${candidate_bin_dir}:${PATH}";
    unset CANDIDATE_BIN_DIR
}
if [[ $0 != "-bash" ]]; then __sdkman_prepend_candidate_to_path "$@"; fi
