scriptify ()
{
    if [[ "$(type "$1")" == *"is a shell builtin" ]]; then
        echo This is a shell builtin.;
    else
        if [[ "$(type "$1")" == *"is aliased to"* ]]; then
            echo This is an alias.;
        else
            # Printing out the contents of the function to a file and making it executable
            type "$1" | tail -n +2 | tee "$1".sh && chmod 755 "$1".sh;
            echo >> "$1".sh

            # Optionally, this code will make the cuntion executable if the -e flag is passed into it.
            # -----
            # echo "if [[ \"\$1\" = \"-e\" ]]; then shift; $1 \"\$@\"; fi" >> "$1".sh;
            # echo 'usage () { echo Print this usage text.; }' >> "$1".sh;
            # echo "if [[ \"\$1\" = \"-h\" ]]; then printf \"Usage: %s [-e|-h]\n\n-e\tExecute this as a script instead of as a function.\n-h\t"'$(usage)'"\n\" \"\$0\"; fi" >> "$1".sh;
        fi;
    fi
}
