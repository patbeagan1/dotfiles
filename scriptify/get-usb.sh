get-usb () 
{ 
    diff <(lsusb) <(sleep 3s && lsusb)
}
if [[ $0 != "-bash" ]]; then get-usb "$@"; fi
