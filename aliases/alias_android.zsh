alias android-list-devices='adb devices -l'
alias android-list-avds='emulator -list-avds'

export P_AVD_CURRENT='Pixel_3a_API_33_arm64-v8a'
export P_PROXY_CURRENT='http://192.168.1.85:8888'
alias android-start-emu='emulator -netdelay none -netspeed full -avd $P_AVD_CURRENT -http-proxy $P_PROXY_CURRENT'