#!/bin/bash

if [[ $1 == post ]]; then
    modprobe -r psmouse
    modprobe psmouse
fi

