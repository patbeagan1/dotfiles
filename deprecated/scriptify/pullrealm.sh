pullrealm () 
{ 
    echo pulling files from the android system so that they can be viewed by the realm browser.;
    mkdir realm-files && cd realm-files && adb root && adb pull /data/data/com.wayfair.wayfair.dev/files/ . && cd -
}
if [[ $0 != "-bash" ]]; then pullrealm "$@"; fi
