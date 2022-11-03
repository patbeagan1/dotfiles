#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

img_wiggle_parallel ()
{
    convert -crop 50%x100% +repage "$1" mid.jpg;
    convert -delay 15 -loop 0 mid*.jpg out.gif
}
img_wiggle_parallel "$@"
trackusage.sh "$0"