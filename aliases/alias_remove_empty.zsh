function remove_empty_lines() { cat "$1" | sed '/^[\w]*$/d'; }
function remove_empty_lines_force() {
    filename="/tmp/tmp-old"
    cp "$1" "$filename"
    remove_empty_lines "$1" >/tmp/tmp && mv /tmp/tmp "$1"
    echo "The original is still at $filename"
    echo "You can verify the changes with 'diff $1 $filename'"
}
