################################
### External scripts, cached ###
################################

. $LIB_CACHE
export SCRIPT_CACHE=~/.script_cache
mkdir -p "$SCRIPT_CACHE"
export PATH=$PATH:"$SCRIPT_CACHE"
fill_script_cache () { cache_get_as_exec "$SCRIPT_CACHE"/"$1".ext.sh "$2"; }

# Start downloads

fill_script_cache curl-basic-auth "https://raw.githubusercontent.com/temptemp3/linuxhint.com/master/curl-basic-auth.sh"
fill_script_cache random-ips "https://raw.githubusercontent.com/temptemp3/linuxhint.com/master/random-ips.sh"

fill_script_cache img_flicker "https://www.imagemagick.org/Usage/scripts/flicker_cmp"
fill_script_cache img_histogram "https://www.imagemagick.org/Usage/scripts/im_histogram"
fill_script_cache img_zoom_blur "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=zoomblur&dirname=zoomblur"
fill_script_cache img_wiggle "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=wiggle&dirname=wiggle"
fill_script_cache img_color_boost "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=colorboost&dirname=colorboost"
fill_script_cache img_bcimage "http://www.fmwconcepts.com/imagemagick/downloadcounter.php?scriptname=bcimage&dirname=bcimage"
