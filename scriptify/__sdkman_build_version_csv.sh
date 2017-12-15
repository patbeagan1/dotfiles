__sdkman_build_version_csv () 
{ 
    local candidate versions_csv;
    candidate="$1";
    versions_csv="";
    if [[ -d "${SDKMAN_CANDIDATES_DIR}/${candidate}" ]]; then
        for version in $(find "${SDKMAN_CANDIDATES_DIR}/${candidate}" -maxdepth 1 -mindepth 1 -exec basename '{}' \; | sort -r);
        do
            if [[ "$version" != 'current' ]]; then
                versions_csv="${version},${versions_csv}";
            fi;
        done;
        versions_csv=${versions_csv%?};
    fi;
    echo "$versions_csv"
}
if [[ $0 != "-bash" ]]; then __sdkman_build_version_csv "$@"; fi
