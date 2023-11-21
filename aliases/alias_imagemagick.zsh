alias chafa-all='for i in *; do chafa "$i"; sleep 0.5; done'


alias convert-list-functions="convert -list"             # list of all functions
alias convert-list="convert -list list"                  # list of all -list options
alias convert-list-channel="convert -list channel"       # list of all image -channel options
alias convert-list-command="convert -list command"       # list of all commands
alias convert-list-color="convert -list color"           # list of all color names and values
alias convert-list-colorspace="convert -list colorspace" # list of all -colorspace options
alias convert-list-compose="convert -list compose"       # list of all -compose options
alias convert-list-configure="convert -list configure"   # list of your IM version information
alias convert-list-decoration="convert -list decoration" # list of all text decorations
alias convert-list-filter="convert -list filter"         # list of all -filter options
alias convert-list-font="convert -list font"             # list of all supported fonts (on your system)
alias convert-list-format="convert -list format"         # list of all image formats
alias convert-list-gravity="convert -list gravity"       # list of all -gravity positioning options
alias convert-list-primitive="convert -list primitive"   # list of all -draw primitive shapes
alias convert-list-style="convert -list style"           # list of all text styles
alias convert-list-threshold="convert -list threshold"   # list of all dither/halftone options
alias convert-list-type="convert -list type"             # list of all image types
alias convert-list-virtual="convert -list virtual-pixel" # list of all -virtual-pixel options

alias img-resize-to-web="mogrify -resize 690\> *.png"
alias img-identify='identify -verbose'
alias img-jpgdir-to-gif="convert -delay 20 -loop 0 *.jpg myimage.gif"


# Usage: imgresize "image.jpg" 400
imgresize() {
    convert "$1" -resize $2x "$1_resized.jpg"
}

# Usage: imgconvert "image.jpg" png
imgconvert() {
    filename=$(basename -- "$1")
    name="${filename%.*}"
    convert "$1" "$name.$2"
}

# Usage: imgcrop "image.jpg" 400x400+10+5
imgcrop() {
    convert "$1" -crop $2 "$1_cropped.jpg"
}

# Usage: imgrotate "image.jpg" 90
imgrotate() {
    convert "$1" -rotate $2 "$1_rotated.jpg"
}

# Usage: imgtext "image.jpg" "Hello World" 
imgtext() {
    convert "$1" -font Arial -pointsize 20 -fill white -annotate +30+30 "$2" "$1_with_text.jpg"
}

# Usage: imgblur "image.jpg"
imgblur() {
    convert "$1" -blur 0x8 "$1_blurred.jpg"
}

# Usage: imgmontage "img1.jpg" "img2.jpg" ... "output.jpg"
imgmontage() {
    # Extract last argument for output file
    output="${@: -1}"
    
    # Remove the last argument (output file)
    inputs="${@:1:$(($#-1))}"
    
    montage -geometry +1+1 $inputs $output
}

# Usage: imgoverlay "background.jpg" "overlay.png"
imgoverlay() {
    composite -gravity center "$2" "$1" "$1_overlay.jpg"
}

# Usage: imgbrighten "image.jpg" 120%
imgbrighten() {
    convert "$1" -modulate $2 "$1_brightened.jpg"
}

# Usage: imgthumb "image.jpg" 150
imgthumb() {
    convert "$1" -thumbnail "$2x$2^" -gravity center -extent $2x$2 "$1_thumbnail.jpg"
}

# Usage: imgopacity "image.png" 70
imgopacity() {
    convert "$1" -alpha set -channel A -evaluate set $2% "$1_opacity.jpg"
}

# Usage: imgautolevel "image.jpg"
imgautolevel() {
    convert "$1" -auto-level "$1_leveled.jpg"
}

# Usage: imgnegative "image.jpg"
imgnegative() {
    convert "$1" -negate "$1_negative.jpg"
}

# Usage: imggray "image.jpg"
imggray() {
    convert "$1" -colorspace Gray "$1_gray.jpg"
}

# Usage: imgborder "image.jpg" 5
imgborder() {
    convert "$1" -bordercolor black -border $2x$2 "$1_border.jpg"
}

# Usage: imgsepia "image.jpg"
imgsepia() {
    convert "$1" -sepia-tone 80% "$1_sepia.jpg"
}

# Usage: imgdenoise "image.jpg"
imgdenoise() {
    convert "$1" -despeckle "$1_denoised.jpg"
}

# Usage: imgtogif "img1.jpg" "img2.jpg" ... "output.gif"
imgtogif() {
    # Extract last argument for output file
    output="${@: -1}"
    
    # Remove the last argument (output file)
    inputs="${@:1:$(($#-1))}"
    
    convert -delay 100 -loop 0 $inputs $output
}

# Usage: extractframes "animation.gif"
extractframes() {
    convert "$1" "$1_frame_%d.jpg"
}
