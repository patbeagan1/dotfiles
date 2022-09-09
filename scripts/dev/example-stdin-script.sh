pr () { echo "'$(cat /dev/stdin)'"; }
echo "$0" | sed 's/^.*\///g' | pr

trackusage.sh "$0"