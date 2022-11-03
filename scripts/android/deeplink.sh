#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

deeplink () 
{ 
    adb shell am start -a android.intent.action.VIEW -d "$1"
}
deeplink "$@"
