__sdkman_determine_current_version () 
{ 
    local candidate present;
    candidate="$1";
    present=$(__sdkman_path_contains "${SDKMAN_CANDIDATES_DIR}/${candidate}");
    if [[ "$present" == 'true' ]]; then
        if [[ "$solaris" == true ]]; then
            CURRENT=$(echo $PATH | gsed -r "s|${SDKMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | gsed -r "s|^.*!!(.+)!!.*$|\1|g");
        else
            if [[ "$darwin" == true ]]; then
                CURRENT=$(echo $PATH | sed -E "s|${SDKMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | sed -E "s|^.*!!(.+)!!.*$|\1|g");
            else
                CURRENT=$(echo $PATH | sed -r "s|${SDKMAN_CANDIDATES_DIR}/${candidate}/([^/]+)/bin|!!\1!!|1" | sed -r "s|^.*!!(.+)!!.*$|\1|g");
            fi;
        fi;
        if [[ "$CURRENT" == "current" ]]; then
            CURRENT=$(readlink "${SDKMAN_CANDIDATES_DIR}/${candidate}/current" | sed "s!${SDKMAN_CANDIDATES_DIR}/${candidate}/!!g");
        fi;
    else
        CURRENT="";
    fi
}
if [[ $0 != "-bash" ]]; then __sdkman_determine_current_version "$@"; fi
