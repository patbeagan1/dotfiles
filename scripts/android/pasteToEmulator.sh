#!/bin/bash 

pasteToEmulator () 
{ 
    adb shell input text "${1}"
}

pasteToEmulator "$@"
