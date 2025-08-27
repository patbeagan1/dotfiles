#!/bin/bash

# Check if a file path is provided
if [ $# -eq 0 ]
then
    echo "Usage: $0 <file_path>"
    exit 1
fi

# Read the file line by line
while IFS= read -r line
do
    # Encode the line for URL usage
    encoded_line=$(echo "$line" | jq -sRr @uri)

    # Construct DuckDuckGo search URL
    search_url="https://duckduckgo.com/?q=$encoded_line&t=h_&ia=web"

    # Open the URL in the default web browser
    xdg-open "$search_url"
    # Uncomment the next line if you are using macOS
    # open "$search_url"
    # Uncomment the next line if you are using Windows
    # start "$search_url"

    # Optional: wait a bit between opening each search to avoid overwhelming your browser
    sleep 2

done < "$1"

