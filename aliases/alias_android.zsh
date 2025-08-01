# Alias to enable developer options on Android devices
alias enable_developer_options="adb shell settings put global development_settings_enabled 1"
# Alias to enable the 'Don't keep activities' option
alias enable_dont_keep_activities="adb shell settings put global always_finish_activities 1"
# Alias to disable the 'Don't keep activities' option
alias disable_dont_keep_activities="adb shell settings put global always_finish_activities 0"

alias android-list-devices='adb devices -l'
alias android-list-avds='emulator -list-avds'

alias android-emulator=~/Library/Android/sdk/emulator/emulator
alias android-start-emulator='em -avd $(em -list-avds | fzf)'
export P_AVD_CURRENT='Pixel_3a_API_33_arm64-v8a'
export P_PROXY_CURRENT='http://192.168.1.85:8888'
alias android-start-network-emu='emulator -netdelay none -netspeed full -avd $P_AVD_CURRENT -http-proxy $P_PROXY_CURRENT'
# Common ADB commands
alias android-reboot='adb reboot'
alias android-reboot-bootloader='adb reboot bootloader'
alias android-reboot-recovery='adb reboot recovery'
alias android-install='adb install'
alias android-uninstall='adb uninstall'
alias android-pull='adb pull'
alias android-push='adb push'
alias android-shell='adb shell'
alias android-logs='adb logcat'
alias android-clear-logs='adb logcat -c'
alias android-screenshot='adb exec-out screencap -p > screenshot.png'
alias android-screenrecord='adb shell screenrecord /sdcard/screenrecord.mp4'
alias android-stop-screenrecord='adb shell pkill -SIGINT screenrecord'
alias android-battery-info='adb shell dumpsys battery'
alias android-wifi-info='adb shell dumpsys wifi'
alias android-app-list='adb shell pm list packages'
alias android-app-info='adb shell dumpsys package'

alias android-start-emu-fzf='emulator -avd $(emulator -list-avds | fzf)'

# Function to search and execute ADB commands using fzf
androidl () {
    local commands=(
        "adb devices -l"
        "adb reboot"
        "adb reboot bootloader"
        "adb reboot recovery"
        "adb install"
        "adb uninstall"
        "adb pull"
        "adb push"
        "adb shell"
        "adb logcat"
        "adb logcat -c"
        "adb exec-out screencap -p > screenshot.png"
        "adb shell screenrecord /sdcard/screenrecord.mp4"
        "adb shell pkill -SIGINT screenrecord"
        "adb shell dumpsys battery"
        "adb shell dumpsys wifi"
        "adb shell pm list packages"
        "adb shell dumpsys package"
        # these are the aliases which are defined above
        # putting them here so that they are easier to discover
        "android-list-devices"
        "android-list-avds"
        "android-emulator"
        "android-start-emulator"
        "android-start-network-emu"
        "android-reboot"
        "android-reboot-bootloader"
        "android-reboot-recovery"
        "android-install"
        "android-uninstall"
        "android-pull"
        "android-push"
        "android-shell"
        "android-logs"
        "android-clear-logs"
        "android-screenshot"
        "android-screenrecord"
        "android-stop-screenrecord"
        "android-battery-info"
        "android-wifi-info"
        "android-app-list"
        "android-app-info"
        "android-start-emu-fzf"
    )
    
    local selected=$(printf '%s\n' "${commands[@]}" | fzf --preview 'echo "Will execute: {}"')
    
    if [ -n "$selected" ]; then
        echo "Executing: $selected"
        eval "$selected"
    fi
}
