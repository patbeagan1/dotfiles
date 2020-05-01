myip () 
{ 
    qrencode -o /tmp/qrcode.png $(ifconfig | grep 'inet 19' | cut -d' ' -f 2 | sed 's/$/:8000/' | sed 's/^/https:\/\//') && open /tmp/qrcode.png
}
