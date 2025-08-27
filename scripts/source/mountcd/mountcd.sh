#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

mountcd () 
{ 
    mount /path/to/file.iso /mnt/cdrom -oloop
}

mountcd "$@"
trackusage.sh "$0"