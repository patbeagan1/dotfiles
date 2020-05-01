# Creates a party gif of a static image by replacing the given color with the "Party Parrot" colors
#
# @param -i --input-file  The filename of the static image file to modify
# @param -c --color       The hex of the color to replace with party colors
# @param -f --fuzz        Threshold used to match pixel color similarity to the given color. 0-100
# @param -o --output-file The filename to output the gif
#
# Sample Request: partify.sh -i static_img.png -c "#000000" -f 10 -o party_img.gif
#
# @author Sean Ezrol
# @author Ross Regitsky

while [[ $# -gt 1 ]]
do
key="$1"
  case $key in
  -i|--input-file)
  INPUTFILE=$2
  shift
  ;;
  -c|--color)
  COLOR=$2
  shift
  ;;
  -f|--fuzz)
  FUZZ=$2
  shift
  ;;
  -o|--output-file)
  OUTPUTFILE=$2
  shift
  ;;
  *)
    # unknown arg
  ;;
esac
shift
done

echo Input - "${INPUTFILE}"
party_colors=("#FA8C8E" "#FCD890" "#36FF89" "#3DFFFC" "#81B8FC" "#F491FF" "#FB8DFC" "#FA69F5" "#FA69B9" "#FA696E" )
for i in "${!party_colors[@]}"
do
  magick convert -fill "${party_colors[i]}" -fuzz "${FUZZ}%" -opaque "${COLOR}" "${INPUTFILE}" temp$i.miff
done

cmd="magick convert -delay 4 -loop 0 -coalesce -layers OptimizeFrame "
for i in "${!party_colors[@]}"
do
  cmd+="temp$i.miff " 
done
cmd+=${OUTPUTFILE}
echo $cmd
eval $cmd

rm temp*.miff
