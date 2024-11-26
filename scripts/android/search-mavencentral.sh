#!/usr/bin/zsh
set -x

url="http://search.maven.org/solrsearch/select"

typeset -A params
params=(
    'rows' '20'
    'wt' 'json'
)

function construct() {
    local isFirst='true'

    for k v in "${(@kv)params}"; do 
        if [ "$isFirst" = 'true' ]; then 
            url="$url?$k=$v"
            ifFirst='false'
        else
            url="$url&$k=$v"
        fi
        echo $url
    done
}

construct

curl "$url&q=$1"
