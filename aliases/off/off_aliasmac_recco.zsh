# Open any file or directory in Finder from the terminal
# Usage: openf "path/to/item"
alias openf='open -R'

# Show/hide hidden files in Finder
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'

# Open the current directory in Finder
alias cf='open -a Finder ./'

# Get the full path to the current directory
alias pwdc='pwd | pbcopy'

# Eject all mounted disks
alias ejectall='diskutil list | grep /dev/disk | awk '\''{print $1}'\'' | xargs -I{} diskutil eject {}'

# Restart Wi-Fi
alias wifi_restart='networksetup -setairportpower en0 off; networksetup -setairportpower en0 on'

# Show/hide the macOS Dock
alias hidedock='defaults write com.apple.dock autohide -bool true; killall Dock'
alias showdock='defaults write com.apple.dock autohide -bool false; killall Dock'

# Flush the DNS cache
alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

# View the list of available wireless networks
alias wifilist='networksetup -listallhardwareports | awk '\''/AirPort|Wi-Fi/{getline; print}'\'' | awk '\''{print $2}'\'' | xargs -I{} /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -s'

# Directly open the System Preferences pane. 
# Usage: prefs "pane-name". For example: prefs "Network"
prefs() {
    open "x-apple.systempreferences:com.apple.preference.$1"
}

# Display battery status in the terminal
alias batterystatus='pmset -g batt'

# Take a screenshot of a specific area and save to the Desktop
alias screenshot='screencapture -i ~/Desktop/screenshot_$(date "+%Y%m%d_%H%M%S").png'

# Take a screenshot of the entire screen and save to the Desktop
alias screensnap='screencapture ~/Desktop/screenshot_$(date "+%Y%m%d_%H%M%S").png'

# Lock the screen
alias lockscreen='/System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend'

# Quick Look any file directly from the terminal
# Usage: ql "file-name"
alias ql='qlmanage -p 2>/dev/null'

# Empty the Trash
alias emptytrash='sudo rm -rf ~/.Trash/*'

# Get the macOS version
alias osversion='sw_vers -productVersion'

# Display the uptime in a more readable format
alias uptime_pretty='uptime | sed "s/, [0-9]* user.*$/m/" | sed "s/ up / Uptime: /" | sed "s/ days, /d /" | sed "s/:/h /"'

# Display all system logs in Console
alias logs='open /Applications/Utilities/Console.app'

# Disable/Enable the Dashboard (pre-macOS Catalina)
alias dashboard_off='defaults write com.apple.dashboard mcx-disabled -bool true && killall Dock'
alias dashboard_on='defaults write com.apple.dashboard mcx-disabled -bool false && killall Dock'

# Forcefully reboot the Mac
alias hardreboot='sudo fseventer restart'

# Start/Stop/Restart a LaunchDaemon or LaunchAgent
# Usage: launchd_start "service-name"
alias launchd_start='sudo launchctl load -w /System/Library/LaunchDaemons/$1.plist'
alias launchd_stop='sudo launchctl unload -w /System/Library/LaunchDaemons/$1.plist'
alias launchd_restart='launchd_stop $1 && launchd_start $1'

# Display disk usage in a human-readable format
alias duh='du -sh'

# Display open network connections
alias connections='lsof -i'

# Show the sizes of all installed applications
alias app_sizes='du -sh /Applications/*'

# Rebuild the Spotlight index
alias rebuild_spotlight='sudo mdutil -E /'

# Display a list of all active processes
alias procs='ps aux'

# See the top processes by CPU and Memory
alias top_procs='top -o cpu'
alias top_mem='top -o rsize'

# List all loaded kernel extensions
alias kexts='kextstat | grep -v com.apple'

# Remove all .DS_Store files recursively from the current directory
alias cleands='find . -type f -name .DS_Store -delete'

# Set default Finder location to Home directory (default is Recent Items)
alias finder_home='defaults write com.apple.finder NewWindowTarget -string "PfHm"'

# Toggle dark mode
alias toggledark="osascript -e 'tell app \"System Events\" to tell appearance preferences to set dark mode to not dark mode'"

# Display the current WiFi network's name
alias wifiname="networksetup -getairportnetwork en0 | cut -d ':' -f 2"

# Mute/Unmute system volume
alias mute="osascript -e 'set volume output muted true'"
alias unmute="osascript -e 'set volume output muted false'"

# Increase/Decrease system volume (adjust number for magnitude of change)
alias volup="osascript -e 'set volume output volume (output volume of (get volume settings) + 10) --100%'"
alias voldown="osascript -e 'set volume output volume (output volume of (get volume settings) - 10) --100%'"

# Sleep the display immediately
alias sleepdisplay="pmset displaysleepnow"

# Toggle between showing and hiding file extensions in Finder
alias toggleext="defaults write NSGlobalDomain AppleShowAllExtensions -bool $(defaults read NSGlobalDomain AppleShowAllExtensions -bool | tr true false | tr false true) && killall Finder"

# Show/Hide path bar in Finder
alias showpathbar="defaults write com.apple.finder ShowPathbar -bool true && killall Finder"
alias hidepathbar="defaults write com.apple.finder ShowPathbar -bool false && killall Finder"

# Clear the clipboard
alias clipclear="pbcopy < /dev/null"

# Open current directory in Terminal (useful when in a non-terminal application)
alias terminal="open -a Terminal.app ."

# Display Bluetooth connection status
alias btstatus="system_profiler SPBluetoothDataType | grep 'Connected: Yes'"

# Quickly access iCloud Drive from Terminal
alias icloud="cd ~/Library/Mobile\ Documents/com~apple~CloudDocs"

# Display all active ports
alias ports="sudo lsof -i -n -P"

# Print the public IP address
alias publicip="curl -s http://ipecho.net/plain"

# Quick shortcut to macOS's "say" command
# Usage: speak "Hello, world!"
alias speak="say"

# Launch any app from the terminal
# Usage: launch "Safari"
launch() {
    open -a "$1"
}

# Reset Launchpad to default layout
alias resetlaunchpad="defaults write com.apple.dock ResetLaunchPad -bool true; killall Dock"

# Toggle dark mode
alias toggledark="osascript -e 'tell app \"System Events\" to tell appearance preferences to set dark mode to not dark mode'"

# Mute/Unmute system volume
alias mute="osascript -e 'set volume output muted true'"
alias unmute="osascript -e 'set volume output muted false'"

# Increase/Decrease system volume (adjust number for magnitude of change)
alias volup="osascript -e 'set volume output volume (output volume of (get volume settings) + 5) --100%'"
alias voldown="osascript -e 'set volume output volume (output volume of (get volume settings) - 5) --100%'"

# Pause/Play current track in Music or Spotify
alias musicpause="osascript -e 'tell application \"Music\" to pause'"
alias musicplay="osascript -e 'tell application \"Music\" to play'"

alias spotifypause="osascript -e 'tell application \"Spotify\" to pause'"
alias spotifyplay="osascript -e 'tell application \"Spotify\" to play'"

# Get the name of the current track playing in Music
alias musictrack="osascript -e 'tell application \"Music\" to name of current track'"

# Get the name of the current track playing in Spotify
alias spotifytrack="osascript -e 'tell application \"Spotify\" to name of current track'"

# Sleep the display immediately
alias sleepdisplay="osascript -e 'tell application \"Finder\" to sleep'"

# Show an alert dialog
# Usage: alert "This is a message"
alert() {
    osascript -e "display alert \"$1\""
}

# Display a notification
# Usage: notify "Title" "Message"
notify() {
    osascript -e "display notification \"$2\" with title \"$1\""
}

# Open a URL in the default browser
# Usage: openurl "http://example.com"
openurl() {
    osascript -e "open location \"$1\""
}

# Create a new reminder in the Reminders app
# Usage: reminder "Buy milk"
reminder() {
    osascript -e "tell application \"Reminders\" to make new reminder with properties {name:\"$1\"}"
}

# Set system volume level (0 to 100)
# Usage: setvol 50
setvol() {
    osascript -e "set volume output volume $1"
}

# Get the currently active app's name
alias activeapp="osascript -e 'tell application \"System Events\" to name of first application process whose frontmost is true'"

# Hide current active application
alias hideactive="osascript -e 'tell application (name of first application process whose frontmost is true) to set visible to false'"

# Toggle WiFi on/off
alias togglewifi="osascript -e 'tell application \"System Events\" to set isRunning to (exists (processes where name is \"AirPort Base Station Agent\"))' -e 'tell application \"System Events\" to if isRunning then do shell script \"networksetup -setairportpower en0 off\" else do shell script \"networksetup -setairportpower en0 on\" end if'"

# Create a new note in the Notes app
# Usage: note "This is a new note content"
note() {
    osascript -e "tell application \"Notes\" to make new note with properties {body:\"$1\"}"
}

# Eject all mounted disks
alias ejectall="osascript -e 'tell application \"Finder\" to eject (every disk whose ejectable is true)'"

# Set the desktop wallpaper
# Usage: setwall "/path/to/image.jpg"
setwall() {
    osascript -e "tell application \"System Events\" to set picture of every desktop to \"$1\""
}

# Lock the screen (require password immediately upon sleep)
alias lockscreen="osascript -e 'tell application \"System Events\" to do shell script \"pmset displaysleepnow\"'"

# Start a new timer in the Timer app (if you use a timer app that supports AppleScript)
# Usage: timer 10 (for a 10-minute timer)
timer() {
    osascript -e "tell application \"Timer\" to start (new timer named \"Command line timer\" for $1 * minutes)"
}

# Minimize all open windows
alias minimizeall="osascript -e 'tell application \"System Events\" to set visible of every process to false'"

# Close all open Finder windows
alias closefinderwindows="osascript -e 'tell application \"Finder\" to close every window'"

# Increase/Decrease screen brightness (0 to 1)
# Usage: brightup 0.1 or brightdown 0.1
brightup() {
    osascript -e "tell application \"System Events\" to tell every screen to set brightness to (current brightness + $1)"
}
brightdown() {
    osascript -e "tell application \"System Events\" to tell every screen to set brightness to (current brightness - $1)"
}

# Update brew and upgrade all packages
alias brewup="brew update && brew upgrade"

# Display list of installed packages
alias brewlist="brew list"

# Search for a package
# Usage: brews packageName
brews() {
    brew search $1
}

# Display information about a package
# Usage: brewinfo packageName
brewinfo() {
    brew info $1
}

# Install a package
# Usage: brewi packageName
brewi() {
    brew install $1
}

# Uninstall a package
# Usage: brewun packageName
brewun() {
    brew uninstall $1
}

# Cleanup old versions and clear cache
alias brewclean="brew cleanup"

# Display outdated packages
alias brewold="brew outdated"

# Display list of services managed by brew services
alias brewsvcs="brew services list"

# Start a service via brew services
# Usage: brewstart serviceName
brewstart() {
    brew services start $1
}

# Stop a service via brew services
# Usage: brewstop serviceName
brewstop() {
    brew services stop $1
}

# Restart a service via brew services
# Usage: brewrestart serviceName
brewrestart() {
    brew services restart $1
}

# Display the brew doctor output
alias brewdoc="brew doctor"

# Display all taps
alias brewtaps="brew tap"

# Pin a formula, preventing it from being upgraded
# Usage: brewpin formulaName
brewpin() {
    brew pin $1
}

# Unpin a formula, allowing it to be upgraded
# Usage: brewunpin formulaName
brewunpin() {
    brew unpin $1
}

# Display current brew configuration
alias brewconfig="brew config"
