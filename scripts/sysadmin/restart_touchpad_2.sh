#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

if [[ $1 == post ]]; then
    modprobe -r psmouse
    modprobe psmouse
fi

