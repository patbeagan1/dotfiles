#!/bin/zsh
set -euo pipefail

nn () {
    local nnfile="$NNFILE"

    local prefix="notes-zizz"
    local bucket="s3://nn-note-bucket"
    local notesRemoteArtifact="$bucket/$prefix.txt.gpg"
    local notesLocalEnc="${HOME}/$prefix.txt.gpg"
    local notesLocal="${HOME}/$prefix.txt"
    local notesRemoteEnc="${HOME}/$prefix-remote.txt.gpg"
    local notesRemote="${HOME}/$prefix-remote.txt"
    local notesBak="${HOME}/$prefix-bak.txt"
    local notesNew="${HOME}/$prefix-new.txt"

    touch "$notesLocal"

    if [[ "help" == "$*" ]]
    then
	    cat << EOF
Usage: $0 [sync] <contents>

If "sync" is the only argument to the script, it will attempt to synchronize the local list with the encrypted list on the server.

If there are no arguments at all, the script will print out the contents of the local list.

If there are any other arguments, they will be stored in the list located at '$notesLocal', with a timestamp.
EOF
    elif [[ "sync" == "$*" ]]
    then
        
        # copy serverside notes to local
        set +e
        aws s3 cp "$notesRemoteArtifact" "$notesRemoteEnc" 
        
        if [[ ! $? -eq 0 ]]; then
            echo There was an issue with downloading the file.
            echo Does the file actually exist? 
            exit 1
        fi	
        set -e
        
        # decrypt notes
        gpg \
            --batch \
            --yes \
            --passphrase-file "$NNFILE" \
            --output "$notesRemote" \
            -d "$notesRemoteEnc" 

        # combine serverside and local notes
        cat "$notesLocal" "$notesRemote" | sort | uniq > "$notesNew"

        # backup current notes
        mv "$notesLocal" "$notesBak"

        # overwrite current notes with the combined notes
        mv "$notesNew" "$notesLocal"

        # printing differences
        diff "$notesBak" "$notesLocal"
        
        # encrypt notes
        gpg \
            --batch \
            --yes \
            --passphrase-file "$NNFILE" \
            -c "$notesLocal" \

        # push the newly combined local notes to the server
        aws s3 cp "$notesLocalEnc" "$bucket"

    elif [ -n "$*" ]
    then
        echo $(date "+%y.%m.%d.%H.%M.%S") "$@" >> "$notesLocal"
    else
        cat "$notesLocal"
    fi
}

nn "$*"
