#!/usr/bin/env zsh

function main() {
  title="$1"
  description="$2"

  curl 'http://localhost:8080/notes/add' -X POST \
    -H 'Accept: text/*' \
    -H 'Accept-Language: en-US,en;q=0.5' \
    -H 'Accept-Encoding: gzip, deflate, br' \
    -H 'Content-Type: application/x-www-form-urlencoded' \
    -H 'Upgrade-Insecure-Requests: 1' \
    -H 'Sec-Fetch-Dest: document' \
    -H 'Sec-Fetch-Mode: navigate' \
    -H 'Sec-Fetch-Site: none' \
    -H 'Sec-Fetch-User: ?1' \
    -H 'Pragma: no-cache' \
    -H 'Cache-Control: no-cache' \
    --data-urlencode 'input-title='"$title" \
    --data-urlencode 'input-content='"$description"
}

if [ $# -ne 2 ]; then
    echo requires a title and a description.
    exit 1
fi

main "$1" "$2"