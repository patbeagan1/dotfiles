#!/bin/bash

qrencode -l L -v 1 -o /tmp/qr-out.png -r <(echo http://"$(ipconfig getifaddr en0)":8000) && open /tmp/qr-out.png
trackusage.sh "$0"