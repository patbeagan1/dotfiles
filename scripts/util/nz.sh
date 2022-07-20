#!/bin/zsh
set -euo pipefail

nn () {
	local prefix="notes-z"
	local notesRemoteArtifact="s3://nn-note-bucket/$prefix.txt.gpg"
	local notesLocalEnc="${HOME}/$prefix.txt.gpg"
	local notesLocal="${HOME}/$prefix.txt"
	local notesRemoteEnc="${HOME}/$prefix-remote.txt.gpg"
	local notesRemote="${HOME}/$prefix-remote.txt"
	local notesBak="${HOME}/$prefix-bak.txt"
	local notesNew="${HOME}/$prefix-new.txt"

	echo "$notesLocal"
	touch "$notesLocal"

	if [[ "sync" == "$*" ]]
	then
	
	# copy serverside notes to local
	set +e
        aws s3 cp "$notesRemoteArtifact" "$notesRemoteEnc" 
	if [[ $? -eq 0 ]]; then
		# decrypt notes
		gpg -d "$notesRemoteEnc" > "$notesRemote"
	else
		touch "$notesRemote"
	fi
	set -e

	# combine serverside and local notes
        cat "$notesLocal" "$notesRemote" | sort | uniq > "$notesNew"

	# backup current notes
        mv "$notesLocal" "$notesBak"

	# overwrite current notes with the combined notes
        mv "$notesNew" "$notesLocal"

	# encrypt notes
	gpg -c "$notesLocal"

	# push the newly combined local notes to the server
        aws s3 cp "$notesLocalEnc" s3://nn-note-bucket

	elif [ -n "$*" ]
	then
		echo $(date "+%y.%m.%d.%H.%M.%S") "$@" >> "$notesLocal"
	else
		cat "$notesLocal"
	fi
}

nn "$*"
