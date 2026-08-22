# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# Linux-only aliases live on jan/system.yaml (`linux-shell`, emitted by `jan alias`).

# Moved to jan scripts/system/fileedit.yaml (`jan scripts system fileedit run`).

function historyrun() {
	local currCommand="$(
		history |
	       	sed 's|^ *||' |
	       	sort -r |
	       	cut -d' ' -f2-99 |
		awk '{$1=$1;print}' |
	       	fzf --no-sort -e
	)"
	shellcolor --bold "$currCommand"
	echo "Press enter to continue, or ctrl-c to exit."
	pause.sh
	eval "$currCommand"
}
