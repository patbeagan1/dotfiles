myip () 
{ 
    qrencode -o /tmp/qrcode.png $(ifconfig | grep 'inet 19' | cut -d' ' -f 2 | sed 's/$/:8000/' | sed 's/^/https:\/\//') && open /tmp/qrcode.png
}

if [[ "$1" = "-e" ]]; then shift; myip "$@"; fi
usage () { echo Print this usage text.; }
if [[ "$1" = "-h" ]]; then printf "Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t$(usage)\n" "$0"; fi
