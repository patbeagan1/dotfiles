alias android-list-devices='adb devices -l'
alias android-list-avds='emulator -list-avds'

alias android-emulator=~/Library/Android/sdk/emulator/emulator
alias android-start-emulator='em -avd $(em -list-avds | fzf)'
export P_AVD_CURRENT='Pixel_3a_API_33_arm64-v8a'
export P_PROXY_CURRENT='http://192.168.1.85:8888'
alias android-start-network-emu='emulator -netdelay none -netspeed full -avd $P_AVD_CURRENT -http-proxy $P_PROXY_CURRENT'
