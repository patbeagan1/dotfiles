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

# fzf launcher for adb commands.
# Usage: Type 'afh' and press Enter.
afh() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v adb &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'adb' to be installed." >&2
    return 1
  fi

  # 2. Get a list of commands by parsing the 'adb help' output
  local commands
  commands=$(adb help | grep -E '^\s+[a-z-]' | awk '{print $1}')
  if [[ -z "$commands" ]]; then
    echo "Error: Could not parse commands from 'adb help'." >&2
    return 1
  fi

  # 3. Set up the fzf preview command
  # Since 'adb help <command>' is not supported, we grep the main help text
  # for the highlighted command's description.
  local preview_cmd
  local grep_cmd="grep -A 3 -E '^\s+{}(\s|\[|$)'"
  if command -v bat &> /dev/null; then
    preview_cmd="adb help | $grep_cmd | bat --color=always -l man -p"
  else
    preview_cmd="adb help | $grep_cmd"
  fi

  # 4. Run fzf to let the user select a command
  local selected_command
  selected_command=$(echo "$commands" | fzf --height 50% --min-height 15 --border --prompt="ADB > " \
    --preview="$preview_cmd" \
    --preview-window='right,70%,border-left')

  # 5. If a command was selected, place it on the command line for editing
  if [[ -n "$selected_command" ]]; then
    print -z "adb ${selected_command} "
  fi
}

# fzf launcher for Android emulators.
# Usage: Type 'avd' and press Enter to select and launch an AVD.
avd() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v emulator &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'emulator' to be installed." >&2
    return 1
  fi

  # 2. Get the list of available AVDs
  local avds
  avds=$(emulator -list-avds)
  if [[ -z "$avds" ]]; then
    echo "No AVDs found. Create one with 'avdmanager create avd ...'" >&2
    return 1
  fi

  # 3. Set up the fzf preview to show the AVD's configuration
  local preview_cmd
  if command -v bat &>/dev/null; then
    preview_cmd="bat --color=always ~/.android/avd/{}.avd/config.ini"
  else
    preview_cmd="cat ~/.android/avd/{}.avd/config.ini"
  fi

  # 4. Run fzf to let the user select an AVD
  local selected_avd
  selected_avd=$(echo "$avds" | fzf --height 40% --prompt="Select AVD to launch > " \
    --preview="$preview_cmd" \
    --preview-window='right,60%,border-left')

  # 5. Launch the selected AVD in the background
  if [[ -n "$selected_avd" ]]; then
    echo "Starting AVD: $selected_avd"
    # Run in background and detach from the shell
    emulator -avd "$selected_avd" &>/dev/null & disown
  fi
}

# fzf helper for avdmanager.
# Usage: Type 'avdm' and press Enter to select an action.
avdm() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v avdmanager &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'avdmanager' to be installed." >&2
    return 1
  fi

  # 2. Define the main avdmanager commands
  local commands="list\ncreate\ndelete\nmove"

  # 3. Set up the fzf preview to show help for the selected action
  local preview_cmd
  if command -v bat &>/dev/null; then
    preview_cmd="avdmanager {} help | bat -l help -p --color=always"
  else
    preview_cmd="avdmanager {} help"
  fi

  # 4. Run fzf to let the user select an action
  local selected_cmd
  selected_cmd=$(echo -e "$commands" | fzf --height 40% --prompt="AVD Manager Action > " \
    --preview="$preview_cmd")

  # 5. Place the selected command on the terminal for editing
  if [[ -n "$selected_cmd" ]]; then
    print -z "avdmanager $selected_cmd "
  fi
}

# fzf helper for sdkmanager.
# Usage: Type 'sdkm' and press Enter to select packages to install.
sdkm() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v sdkmanager &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'sdkmanager' to be installed." >&2
    return 1
  fi

  # 2. Get a list of all available and installed SDK packages
  # We use --no_https to speed up the listing process significantly.
  echo "Fetching SDK package list..."
  local packages
  packages=$(sdkmanager --list --no_https 2>/dev/null)

  # 3. Run fzf with multi-select enabled
  local selected_lines
  selected_lines=$(echo "$packages" | fzf --multi --height 70% --prompt="SDK Manager Packages > ")

  # 4. Build the install command from the selected packages
  if [[ -n "$selected_lines" ]]; then
    # Extract the first column (the package string) from each selected line
    local packages_to_install
    packages_to_install=$(echo "$selected_lines" | awk '{print $1}' | tr '\n' ' ')
    print -z "sdkmanager \"$packages_to_install\""
  fi
}