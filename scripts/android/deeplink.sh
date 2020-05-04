#!/bin/bash 

deeplink () 
{ 
    adb shell am start -a android.intent.action.VIEW -d "$1"
}
deeplink "$@"
