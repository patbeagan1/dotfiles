lint-brickkit () 
{ 
    cd /Users/pbeagan/android/brickkit-android/BrickKit && ./gradlew build connectedCheck createPom
}
if [[ $0 != "-bash" ]]; then lint-brickkit "$@"; fi
