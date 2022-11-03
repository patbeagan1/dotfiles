#!/bin/bash
# (c) 2022 Pat Beagan: MIT License

getgateway () { ag -g $1 }
rm /tmp/imgoutput.html
for i in $(getgateway $1); do 
    echo "<p>$i</p><img src='file://$(pwd)/$i' style='width: 100px' />" >> /tmp/imgoutput.html; 
done
open /tmp/imgoutput.html