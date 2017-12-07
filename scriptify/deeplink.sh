deeplink () 
{ 
    adb shell am start -a android.intent.action.VIEW -d "$1"
}
if [[ $0 != "-bash" ]]; then deeplink "$@"; fi
