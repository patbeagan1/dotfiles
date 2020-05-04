. $LIB_RANDOM

cache_format_download ()
{
    cache_format_prefetch () {
        echo "###########"
        echo Downloading: "$1" as "$2"
        echo "###########"
        echo
    }
    
    cache_format_postfetch () {
        if [ $1 -eq 0 ]; then
            echo
            echo "#################"
            echo Download Complete:
            echo "  $2"
            echo "#################"
            echo
        else
            echo
            echo "#############"
            echo DOWNLOAD ERROR
            echo "#############"
            echo
        fi
    }

    cache_format_prefetch "$1" "$2"
    curl "$1" -o "$2" | cat
    result=$?
    cache_format_postfetch $result "$2"
    return $result
}

cache_get () {
    # Checks to see if a file exists, and if it does not, it grabs the file from a given URL
    local remote="$2"
    local cached="$1"
    if [ ! -f "$cached" ]; then
        cache_format_download "$remote" "$cached"
    fi
}

cache_get_as_exec () {
    local remote="$2"
    local cached="$1"
    if [ ! -f "$cached" ]; then
        echo ! Executable Download !
        cache_format_download "$remote" "$cached" && chmod 755 "$cached"
    fi
}

cache_temp ()
{
    cache_format_download "$1" `temp_file`
}
alias grab_page="cache_temp"

cache_temp_as_exec ()
{
    local remote="$1"
    local cached=`temp_file`
    cache_format_download "$remote" "$cached" && chmod 755 "$cached"
}
alias grab_page_as_exec="cache_temp_as_exec"

cache_source_remote ()
{
    local remote="$1"
    local cached=`temp_file`
    cache_format_download "$remote" "$cached" && source "$cached"
}
alias grab_page_and_source="source_remote"
alias source_remote="cache_source_remote"
