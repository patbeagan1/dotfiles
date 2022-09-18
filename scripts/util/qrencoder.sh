qr() {
    local filename="/tmp/qr-output-$(python3 -c 'import time; print(time.time())').png"
    qrencode -l L -v 1 -o "$filename" "$1" &&
        echo "$filename" &&
        open "$filename"
}
qr "$1"
trackusage.sh "$0"
