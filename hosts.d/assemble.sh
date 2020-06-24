assemble () {
    mkdir -p build
    touch build/hosts
	mv build/hosts build/hosts.bak
    find . -name "*.txt" \
        | xargs -I % sh -c '\
        echo \#% >> build/hosts && \
        cat % >> build/hosts && \
        echo "


" >> build/hosts'
}
assemble
