qr ()
{
    qrencode -l L -v 1 -o output.png -r "$1"
}
textToQR ()
{
    qrencode -l L -v 1 -o output"$(python3 -c 'import time; print(time.time())')".png "$1"
}
compileAggregateQR () {
    montage output*  -geometry 120x120+1+1   montage.out.jpg
}