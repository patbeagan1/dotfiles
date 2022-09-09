#!/bin/bash

filename="index.html"

echo > "$filename"

echo '<div>' >> "$filename"
for i in $(find -L . \( ! -regex '.*/\..*' \) -type f -prune); do
echo "<a href=\"$i\"><img src=\"$i\" loading=\"lazy\"></a>" >> "$filename"
done
echo '</div>' >> "$filename"

cat <<EOF >> "$filename"
<style>
img {
    background-color: #eee;
    display: inline-block;
    margin: 0 0 1em;
    max-width: 24%;
    max-height:50%;
}

img:hover {
    -webkit-transform:scale(1.25); /* Safari and Chrome */
    -moz-transform:scale(1.25); /* Firefox */
    -ms-transform:scale(1.25); /* IE 9 */
    -o-transform:scale(1.25); /* Opera */
     transform:scale(1.25);
}
</style>
EOF

trackusage.sh "$0"
