deeplink () 
{ 
    adb shell am start -a android.intent.action.VIEW -d "$1"
}

if [[ "$1" = "-e" ]]; then shift; deeplink "$@"; fi
