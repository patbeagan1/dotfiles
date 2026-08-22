# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# Alias to enable developer options on Android devices
# Alias to enable the 'Don't keep activities' option
# Alias to disable the 'Don't keep activities' option

export P_AVD_CURRENT='Pixel_3a_API_33_arm64-v8a'
export P_PROXY_CURRENT='http://192.168.1.85:8888'
# Common ADB commands

# Shortcut for bin/adb-triage — Android crash triage helpers.

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
