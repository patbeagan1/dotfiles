#!/bin/bash

# ittyShow() {  open $(itty.sh $(echo -n "$@" | sed -e ':a' -e 'N' -e '$!ba' -e 's/\n/<br>/g'));  }
itty () 
{ 
    echo -n "$@" | lzma -9 | base64 | xargs -0 printf "https://itty.bitty.site/#/%s\n"
}

itty "$@"
