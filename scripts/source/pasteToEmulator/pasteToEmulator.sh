#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

pasteToEmulator () 
{ 
    adb shell input text "${1}"
}

pasteToEmulator "$@"
