#!/bin/bash 

mountcd () 
{ 
    mount /path/to/file.iso /mnt/cdrom -oloop
}

mountcd "$@"
