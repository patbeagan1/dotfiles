# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# Alias to enable developer options on Android devices
# alias enable_developer_options="adb shell settings put global development_settings_enabled 1"
# Alias to enable the 'Don't keep activities' option
# alias enable_dont_keep_activities="adb shell settings put global always_finish_activities 1"
# Alias to disable the 'Don't keep activities' option
# alias disable_dont_keep_activities="adb shell settings put global always_finish_activities 0"

# alias android-list-devices='adb devices -l'
# alias android-list-avds='emulator -list-avds'

# alias android-emulator=~/Library/Android/sdk/emulator/emulator
# alias android-start-emulator='em -avd $(em -list-avds | fzf)'
export P_AVD_CURRENT='Pixel_3a_API_33_arm64-v8a'
export P_PROXY_CURRENT='http://192.168.1.85:8888'
# alias android-start-network-emu='emulator -netdelay none -netspeed full -avd $P_AVD_CURRENT -http-proxy $P_PROXY_CURRENT'
# Common ADB commands
# alias android-reboot='adb reboot'
# alias android-reboot-bootloader='adb reboot bootloader'
# alias android-reboot-recovery='adb reboot recovery'
# alias android-install='adb install'
# alias android-uninstall='adb uninstall'
# alias android-pull='adb pull'
# alias android-push='adb push'
# alias android-shell='adb shell'
# alias android-logs='adb logcat'
# alias android-clear-logs='adb logcat -c'
# alias android-screenshot='adb exec-out screencap -p > screenshot.png'
# alias android-screenrecord='adb shell screenrecord /sdcard/screenrecord.mp4'
# alias android-stop-screenrecord='adb shell pkill -SIGINT screenrecord'
# alias android-battery-info='adb shell dumpsys battery'
# alias android-wifi-info='adb shell dumpsys wifi'
# alias android-app-list='adb shell pm list packages'
# alias android-app-info='adb shell dumpsys package'

# alias android-start-emu-fzf='emulator -avd $(emulator -list-avds | fzf)'

# alias android-record='scrcpy -m720 --max-fps=60 -d --record=file.mp4 && mv file.mp4 ~/Downloads'

# Shortcut for bin/adb-triage — Android crash triage helpers.
# alias adbt='adb-triage'

# Function to search and execute ADB commands using fzf
# Moved to jan scripts/android/androidl.yaml (`jan scripts android androidl run`).

# fzf launcher for Android Developer Options toggles via adb, grouped and colorized by action.
# Usage: Type 'adevopts' and select a toggle to apply to the current emulator/device.
# Moved to jan scripts/android/adevopts.yaml (`jan scripts android adevopts run`).



# fzf launcher for adb commands.
# Usage: Type 'afh' and press Enter.
# Moved to jan scripts/android/adb-fzf-help.yaml (`jan scripts android adb-fzf-help run`).
unalias adb-fzf-help 2>/dev/null
adb-fzf-help() { local cmd; cmd="$(jan --no-log scripts android adb-fzf-help run "$@")" && [[ -n "$cmd" ]] && print -z "$cmd"; }

# fzf launcher for Android emulators.
# Usage: Type 'avd' and press Enter to select and launch an AVD.
# Moved to jan scripts/android/emulator-fzf-help.yaml (`jan scripts android emulator-fzf-help run`).

# fzf helper for avdmanager.
# Usage: Type 'avdm' and press Enter to select an action.
# Moved to jan scripts/android/avdmanager-fzf-help.yaml (`jan scripts android avdmanager-fzf-help run`).
unalias avdmanager-fzf-help 2>/dev/null
avdmanager-fzf-help() { local cmd; cmd="$(jan --no-log scripts android avdmanager-fzf-help run "$@")" && [[ -n "$cmd" ]] && print -z "$cmd"; }

# fzf helper for sdkmanager.
# Usage: Type 'sdkm' and press Enter to select packages to install.
# Moved to jan scripts/android/sdkmanager-fzf-help.yaml (`jan scripts android sdkmanager-fzf-help run`).
unalias sdkmanager-fzf-help 2>/dev/null
sdkmanager-fzf-help() { local cmd; cmd="$(jan --no-log scripts android sdkmanager-fzf-help run "$@")" && [[ -n "$cmd" ]] && print -z "$cmd"; }
