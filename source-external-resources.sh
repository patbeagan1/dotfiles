
########################################################
### External static imports, for convenience, cached ###
########################################################

export IMG_CACHE=~/.img_cache
mkdir -p "$IMG_CACHE"
fill_img_cache () { cache_get "$IMG_CACHE"/"$1" "$2"; }

# Start downloads

fill_img_cache scenic.jpg "http://images.hdrsoft.com/images/contest/realistic_prize1_spring2015.jpg"
fill_img_cache parallel.jpg "https://i.imgur.com/mmdO5bx.png"
fill_img_cache transparency.png "http://www.netpulse.com/overview-src/img/connect-icon-transparent.png"