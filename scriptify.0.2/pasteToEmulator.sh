pasteToEmulator () 
{ 
    adb shell input text "${1}"
}

if [[ "$1" = "-e" ]]; then shift; pasteToEmulator "$@"; fi
