#!/usr/bin/env zsh

set -euo pipefail
IFS=$'\n\t'

help() {
    error_code=$?
    echo "
No help message yet
"
    if [[ ! $error_code -eq 0 ]]; then echo "Err: $error_code"; fi
}

q() {
    local content='https://duckduckgo.com/'
    
    content+=$(echo "$@" | sed 's/ /%20/g')
    content+='%20'

    # blocklist
    content+='-site%3Aquora.com%20'
    content+='-site%3Ayummly.com%20'
    content+='-site%3Aamazon.com%20'
    content+='-site%3Atripadvisor.com%20'
    content+='-site%3Aexpedia.com%20'
    content+='-site%3Afacebook.com%20'
    content+='-site%3Amicrosoft.com%20'


    if isMac.sh; then
        open -a Safari "$content"
    else
        firefox "$content"
    fi
}

q "$@" || help
trackusage.sh "$0"
