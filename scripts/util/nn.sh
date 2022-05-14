#!/bin/zsh
set -euo pipefail

nn () {
	if [[ "sync" == "$*" ]]
	then
		# copy serverside notes to local
        aws s3 cp s3://nn-note-bucket/notes.txt ~/notes-remote.txt
		# combine serverside and local notes
        cat ~/notes.txt ~/notes-remote.txt | sort | uniq > ~/notes-new.txt
		# backup current notes
        mv ~/notes.txt ~/notes-bak.txt
		# overwrite current notes with the combined notes
        mv ~/notes-new.txt ~/notes.txt
		# push the newly combined local notes to the server
        aws s3 cp ~/notes.txt s3://nn-note-bucket
	elif [ -n "$*" ]
	then
		echo $(date "+%y.%m.%d.%H.%M.%S") "$@" >> ~/notes.txt
	else
		cat ~/notes.txt
	fi
}

nn "$*"
