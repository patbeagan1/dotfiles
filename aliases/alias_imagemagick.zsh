# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# alias chafa-all='for i in *; do chafa "$i"; sleep 0.5; done'


# alias convert-list-functions="convert -list"             # list of all functions
# alias convert-list="convert -list list"                  # list of all -list options
# alias convert-list-channel="convert -list channel"       # list of all image -channel options
# alias convert-list-command="convert -list command"       # list of all commands
# alias convert-list-color="convert -list color"           # list of all color names and values
# alias convert-list-colorspace="convert -list colorspace" # list of all -colorspace options
# alias convert-list-compose="convert -list compose"       # list of all -compose options
# alias convert-list-configure="convert -list configure"   # list of your IM version information
# alias convert-list-decoration="convert -list decoration" # list of all text decorations
# alias convert-list-filter="convert -list filter"         # list of all -filter options
# alias convert-list-font="convert -list font"             # list of all supported fonts (on your system)
# alias convert-list-format="convert -list format"         # list of all image formats
# alias convert-list-gravity="convert -list gravity"       # list of all -gravity positioning options
# alias convert-list-primitive="convert -list primitive"   # list of all -draw primitive shapes
# alias convert-list-style="convert -list style"           # list of all text styles
# alias convert-list-threshold="convert -list threshold"   # list of all dither/halftone options
# alias convert-list-type="convert -list type"             # list of all image types
# alias convert-list-virtual="convert -list virtual-pixel" # list of all -virtual-pixel options

# alias img-resize-to-web="mogrify -resize 690\> *.png"
# alias img-identify='identify -verbose'
# alias img-jpgdir-to-gif="convert -delay 20 -loop 0 *.jpg myimage.gif"


# Usage: imgresize "image.jpg" 400
# Moved to jan scripts/media/imgresize.yaml (`jan scripts media imgresize run`).

# Usage: imgconvert "image.jpg" png
# Moved to jan scripts/media/imgconvert.yaml (`jan scripts media imgconvert run`).

# Usage: imgcrop "image.jpg" 400x400+10+5
# Moved to jan scripts/media/imgcrop.yaml (`jan scripts media imgcrop run`).

# Usage: imgrotate "image.jpg" 90
# Moved to jan scripts/media/imgrotate.yaml (`jan scripts media imgrotate run`).

# Usage: imgtext "image.jpg" "Hello World" 
# Moved to jan scripts/media/imgtext.yaml (`jan scripts media imgtext run`).

# Usage: imgblur "image.jpg"
# Moved to jan scripts/media/imgblur.yaml (`jan scripts media imgblur run`).

# Usage: imgmontage "img1.jpg" "img2.jpg" ... "output.jpg"
# Moved to jan scripts/media/imgmontage.yaml (`jan scripts media imgmontage run`).

# Usage: imgoverlay "background.jpg" "overlay.png"
# Moved to jan scripts/media/imgoverlay.yaml (`jan scripts media imgoverlay run`).

# Usage: imgbrighten "image.jpg" 120%
# Moved to jan scripts/media/imgbrighten.yaml (`jan scripts media imgbrighten run`).

# Usage: imgthumb "image.jpg" 150
# Moved to jan scripts/media/imgthumb.yaml (`jan scripts media imgthumb run`).

# Usage: imgopacity "image.png" 70
# Moved to jan scripts/media/imgopacity.yaml (`jan scripts media imgopacity run`).

# Usage: imgautolevel "image.jpg"
# Moved to jan scripts/media/imgautolevel.yaml (`jan scripts media imgautolevel run`).

# Usage: imgnegative "image.jpg"
# Moved to jan scripts/media/imgnegative.yaml (`jan scripts media imgnegative run`).

# Usage: imggray "image.jpg"
# Moved to jan scripts/media/imggray.yaml (`jan scripts media imggray run`).

# Usage: imgborder "image.jpg" 5
# Moved to jan scripts/media/imgborder.yaml (`jan scripts media imgborder run`).

# Usage: imgsepia "image.jpg"
# Moved to jan scripts/media/imgsepia.yaml (`jan scripts media imgsepia run`).

# Usage: imgdenoise "image.jpg"
# Moved to jan scripts/media/imgdenoise.yaml (`jan scripts media imgdenoise run`).

# Usage: imgtogif "img1.jpg" "img2.jpg" ... "output.gif"
# Moved to jan scripts/media/imgtogif.yaml (`jan scripts media imgtogif run`).

# Usage: extractframes "animation.gif"
# Moved to jan scripts/media/extractframes.yaml (`jan scripts media extractframes run`).
