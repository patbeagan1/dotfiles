#!/bin/bash 
# (c) 2022 Pat Beagan: MIT License

speedtest () 
{ 
    dd if=/dev/zero of=/dev/null bs=1M count=32768
}

speedtest "$@"
