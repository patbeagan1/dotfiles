#!/bin/bash

convert "$1" -crop 2x1@  +repage  +adjoin out.png
montage -mode concatenate -tile 2x1@ $(ls -1 out* | sort -r) mon-out.png
