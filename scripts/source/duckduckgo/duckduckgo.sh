#!/usr/bin/env zsh
# (c) 2022 Pat Beagan: MIT License

set -euo pipefail
IFS=$'\n\t'

scriptname="$(basename "$0")"

help() {
    error_code=$?
    echo "
Usage: $scriptname [-h|--help] <search_terms>

Performs a DuckDuckGo search with automatic site exclusions.
Opens the search results in Safari (macOS) or Firefox (Linux).

Arguments:
  search_terms    Search query (multiple words supported)

Features:
  - Automatically excludes common low-quality sites
  - Opens in default browser (Safari/Firefox)
  - URL-encodes search terms
  - Cross-platform support

Excluded sites:
  - Quora, Yummly, Amazon, TripAdvisor
  - Expedia, Facebook, Microsoft

Examples:
  $scriptname 'how to install python'
  $scriptname 'best restaurants in san francisco'
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
