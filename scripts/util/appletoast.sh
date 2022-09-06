#!/bin/bash 

appletoast () 
{ 
    title="$1";
    body="$2";
    osascript -e 'on run {body, title}' -e 'display notification {body} with title {title}' -e 'end run' "$body" "$title"
}
appletoast "$@"
trackusage.sh "$0"