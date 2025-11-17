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

alias android-record='scrcpy -m720 --max-fps=60 -d --record=file.mp4 && mv file.mp4 ~/Downloads'

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

# fzf launcher for Android Developer Options toggles via adb, grouped and colorized by action.
# Usage: Type 'adevopts' and select a toggle to apply to the current emulator/device.
adevopts() {
  if ! command -v fzf &>/dev/null || ! command -v adb &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'adb' to be installed." >&2
    return 1
  fi

  # ANSI color codes for grouping
  local RED=$'\033[0;31m'
  local GREEN=$'\033[0;32m'
  local YELLOW=$'\033[0;33m'
  local BLUE=$'\033[0;34m'
  local CYAN=$'\033[0;36m'
  local MAGENTA=$'\033[0;35m'
  local RESET=$'\033[0m'

  # Use a temp file to store: description|command|color
  local tmpfile
  tmpfile=$(mktemp /tmp/adevopts.XXXXXX)

  # Write all options to the temp file: description|command|color
  cat > "$tmpfile" <<EOF
Layout bounds: show|adb shell setprop debug.layout true|$GREEN
Layout bounds: hide|adb shell setprop debug.layout false|$RED

GPU overdraw: show|adb shell setprop debug.hwui.overdraw show|$GREEN
GPU overdraw: hide|adb shell setprop debug.hwui.overdraw false|$RED
GPU overdraw: debug|adb shell setprop debug.hwui.overdraw debug|$YELLOW

Pointer location: show|adb shell settings put system pointer_location 1|$GREEN
Pointer location: hide|adb shell settings put system pointer_location 0|$RED

Touches: show|adb shell settings put system show_touches 1|$GREEN
Touches: hide|adb shell settings put system show_touches 0|$RED

CPU usage: show|adb shell setprop debug.cpuusage true|$GREEN
CPU usage: hide|adb shell setprop debug.cpuusage false|$RED

ANR dialog: show|adb shell settings put global anr_show_background 1|$GREEN
ANR dialog: hide|adb shell settings put global anr_show_background 0|$RED

Strict mode: enable|adb shell setprop persist.sys.strictmode.visual 1|$GREEN
Strict mode: disable|adb shell setprop persist.sys.strictmode.visual 0|$RED

GPU rendering profile: bars|adb shell settings put global debug_hwui_profile bars|$GREEN
GPU rendering profile: lines|adb shell settings put global debug_hwui_profile lines|$CYAN
GPU rendering profile: graph|adb shell settings put global debug_hwui_profile graph|$CYAN
GPU rendering profile: off|adb shell settings put global debug_hwui_profile off|$RED

Force GPU rendering: enable|adb shell settings put global force_gpu_rendering 1|$GREEN
Force GPU rendering: disable|adb shell settings put global force_gpu_rendering 0|$RED

Don't keep activities: enable|adb shell settings put global always_finish_activities 1|$GREEN
Don't keep activities: disable|adb shell settings put global always_finish_activities 0|$RED

USB debugging: enable|adb shell settings put global adb_enabled 1|$GREEN
USB debugging: disable|adb shell settings put global adb_enabled 0|$RED

Stay awake while charging: enable|adb shell settings put global stay_on_while_plugged_in 3|$GREEN
Stay awake while charging: only AC|adb shell settings put global stay_on_while_plugged_in 1|$YELLOW
Stay awake while charging: only USB|adb shell settings put global stay_on_while_plugged_in 2|$YELLOW
Stay awake while charging: disable|adb shell settings put global stay_on_while_plugged_in 0|$RED

Background processes limit: none (unlimited)|adb shell settings put global limit_background_processes 0|$YELLOW
Background processes limit: standard (4)|adb shell settings put global limit_background_processes 4|$YELLOW
Background processes limit: 1|adb shell settings put global limit_background_processes 1|$YELLOW
Background processes limit: 2|adb shell settings put global limit_background_processes 2|$YELLOW
Background processes limit: 3|adb shell settings put global limit_background_processes 3|$YELLOW
Background processes limit: 4|adb shell settings put global limit_background_processes 4|$YELLOW
Background processes limit: 5|adb shell settings put global limit_background_processes 5|$YELLOW
Background processes limit: 10|adb shell settings put global limit_background_processes 10|$YELLOW

Animation scales: set to 0 (off)|adb shell settings put global window_animation_scale 0; adb shell settings put global transition_animation_scale 0; adb shell settings put global animator_duration_scale 0|$CYAN
Animation scales: set to 0.25x|adb shell settings put global window_animation_scale 0.25; adb shell settings put global transition_animation_scale 0.25; adb shell settings put global animator_duration_scale 0.25|$CYAN
Animation scales: set to 0.5x|adb shell settings put global window_animation_scale 0.5; adb shell settings put global transition_animation_scale 0.5; adb shell settings put global animator_duration_scale 0.5|$CYAN
Animation scales: set to 1x|adb shell settings put global window_animation_scale 1; adb shell settings put global transition_animation_scale 1; adb shell settings put global animator_duration_scale 1|$CYAN
Animation scales: set to 1.5x|adb shell settings put global window_animation_scale 1.5; adb shell settings put global transition_animation_scale 1.5; adb shell settings put global animator_duration_scale 1.5|$CYAN
Animation scales: set to 2x|adb shell settings put global window_animation_scale 2; adb shell settings put global transition_animation_scale 2; adb shell settings put global animator_duration_scale 2|$CYAN
Animation scales: set to 5x|adb shell settings put global window_animation_scale 5; adb shell settings put global transition_animation_scale 5; adb shell settings put global animator_duration_scale 5|$CYAN
Animation scales: set to 10x|adb shell settings put global window_animation_scale 10; adb shell settings put global transition_animation_scale 10; adb shell settings put global animator_duration_scale 10|$CYAN

Demo mode: enable|adb shell settings put global sysui_demo_allowed 1; adb shell am broadcast -a com.android.systemui.demo -e command enter|$MAGENTA
Demo mode: disable|adb shell am broadcast -a com.android.systemui.demo -e command exit|$MAGENTA
Battery (demo mode): set to 100%|adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 100 -e plugged false|$MAGENTA
Battery (demo mode): set to 75%|adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 75 -e plugged false|$MAGENTA
Battery (demo mode): set to 50%|adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 50 -e plugged false|$MAGENTA
Battery (demo mode): set to 20%|adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 20 -e plugged false|$MAGENTA
Battery (demo mode): set to 5%|adb shell am broadcast -a com.android.systemui.demo -e command battery -e level 5 -e plugged false|$MAGENTA
Network (demo mode): show as full|adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4 -e mobile show -e datatype lte -e level 4|$MAGENTA
Network (demo mode): show as none|adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi hide -e mobile hide|$MAGENTA
Network (demo mode): show as 3G|adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 2 -e mobile show -e datatype 3g -e level 2|$MAGENTA
Network (demo mode): show as 4G|adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 3 -e mobile show -e datatype 4g -e level 3|$MAGENTA
Network (demo mode): show as LTE|adb shell am broadcast -a com.android.systemui.demo -e command network -e wifi show -e level 4 -e mobile show -e datatype lte -e level 4|$MAGENTA
Notifications (demo mode): hide|adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible false|$MAGENTA
Notifications (demo mode): show|adb shell am broadcast -a com.android.systemui.demo -e command notifications -e visible true|$MAGENTA
Clock (demo mode): set to 12:34|adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 1234|$MAGENTA
Clock (demo mode): set to 09:00|adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 0900|$MAGENTA
Clock (demo mode): set to 18:45|adb shell am broadcast -a com.android.systemui.demo -e command clock -e hhmm 1845|$MAGENTA

Data saver: enable|adb shell settings put global data_saver_mode 1|$CYAN
Data saver: disable|adb shell settings put global data_saver_mode 0|$CYAN

Show surface updates: enable|adb shell setprop debug.hwui.show_dirty_regions true|$GREEN
Show surface updates: disable|adb shell setprop debug.hwui.show_dirty_regions false|$RED

Show hardware layers updates: enable|adb shell setprop debug.hwui.show_layers_updates true|$GREEN
Show hardware layers updates: disable|adb shell setprop debug.hwui.show_layers_updates false|$RED

Show GPU view updates: enable|adb shell setprop debug.hwui.show_non_rect_clip true|$GREEN
Show GPU view updates: disable|adb shell setprop debug.hwui.show_non_rect_clip false|$RED

Force RTL layout direction: enable|adb shell settings put global debug.force_rtl 1|$CYAN
Force RTL layout direction: disable|adb shell settings put global debug.force_rtl 0|$CYAN
EOF

  # Build the fzf input: colorized description, sorted before coloring
  local fzf_input
  fzf_input=$(sort "$tmpfile" | uniq | awk -F'|' -v reset="$RESET" '{print $3 $1 reset}')

  # fzf: show colorized label, preview the shell command (no color in preview, sorted options)
  local selected_label
  selected_label=$(echo "$fzf_input" | \
    fzf --ansi \
        --color="hl:-1:underline,hl+:-1:underline:reverse" \
        --prompt="Dev Option > " --height=50% --border \
        --preview='
          label=$(echo {} | sed "s/\x1b\[[0-9;]*m//g")
          entry=$(awk -F"|" -v desc="$label" '\''$1 == desc {print $0}'\'' '"$tmpfile"')
          cmd=$(echo "$entry" | awk -F"|" '\''{print $2}'\'')
          if [[ -n "$cmd" ]]; then
            echo "$cmd"
          fi
        ' \
        --preview-window='down,3,wrap')

  # Remove color codes for lookup
  selected_label=$(echo "$selected_label" | sed "s/\x1b\[[0-9;]*m//g")

  if [[ -n "$selected_label" ]]; then
    # Find the line in the tmpfile
    local entry
    entry=$(awk -F"|" -v desc="$selected_label" '$1 == desc {print $0}' "$tmpfile")
    local cmd
    cmd=$(echo "$entry" | awk -F"|" '{print $2}')
    echo "Applying: $cmd"
    eval "$cmd"
  fi

  # Clean up
  rm -f "$tmpfile"
}



# fzf launcher for adb commands.
# Usage: Type 'afh' and press Enter.
adb-fzf-help() {
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
emulator-fzf-help() {
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
avdmanager-fzf-help() {
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
sdkmanager-fzf-help() {
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
