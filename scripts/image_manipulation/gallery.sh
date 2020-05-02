#!/bin/bash 

filename="index.html"

echo > "$filename"

echo '<div class="masonry">' >> "$filename"
for i in $(find . \( ! -regex '.*/\..*' \) -type f); do
echo "<img src=\"$i\">" >> "$filename"
done
echo '</div>' >> "$filename"

cat <<EOF >> "$filename"
<style>
img {
    background-color: #eee;
    display: inline-block;
    margin: 0 0 1em;
    width: 100%;
}

img:hover {
    -webkit-transform:scale(1.25); /* Safari and Chrome */
    -moz-transform:scale(1.25); /* Firefox */
    -ms-transform:scale(1.25); /* IE 9 */
    -o-transform:scale(1.25); /* Opera */
     transform:scale(1.25);
}

.masonry { /* Masonry container */
    column-count: 4;
    column-gap: 1em;
}
</style>
EOF
