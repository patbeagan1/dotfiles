# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.

##Monorepo
# mdo: Run monorepo commands for the current project directory
# Usage: mdo <script_name> [args...]
# Example: When in artrank directory, "mdo start" executes "../monorepo run artrank start"
# Moved to jan scripts/misc/mdo.yaml (`jan scripts misc mdo run`).

# Moved to jan scripts/misc/prettyCSV.yaml (`jan scripts misc prettyCSV run`).

# foreach-line; do echo "$line"; done < alias

# Moved to jan scripts/misc/color-describe.yaml (`jan scripts misc color-describe run`).

# Moved to jan scripts/misc/script-edit.yaml (`jan scripts misc script-edit run`).

# Nordvpn
# fzf launcher for the nordvpn CLI.
# Usage: Type 'nv' and press Enter.
# Moved to jan scripts/misc/nv.yaml (`jan scripts misc nv run`).
unalias nv 2>/dev/null
nv() { local cmd; cmd="$(jan --no-log scripts misc nv run "$@")" && [[ -n "$cmd" ]] && print -z "$cmd"; }

# Moved to jan scripts/misc/ipfs-upload.yaml (`jan scripts misc ipfs-upload run`).
# Moved to jan scripts/misc/unpin_all.yaml (`jan scripts misc unpin_all run`).

# Moved to jan scripts/misc/manu.yaml (`jan scripts misc manu run`).

# Simple encryption and decryption

# Does the same thing as `find . -name` but faster.

# caching web pages for offline viewing
# esp for gutenburg

# Moved to jan scripts/misc/caturl.yaml (`jan scripts misc caturl run`).

#===========================
# Notes

# # Fuzzy search through history and insert the selected command on the command line (zsh only)
# fzf-history-widget() {
#   local selected
#   selected=$(history | sed 's/^ *//g' | cut -d' ' -f3-99 | fzf --height 40% --reverse --prompt="History> ")
#   if [[ -n "$selected" ]]; then
#     LBUFFER+="$selected"
#     zle reset-prompt
#   fi
# }
# zle -N fzf-history-widget
# bindkey '^R' fzf-history-widget

#==========================================
# Random

#==========================================
# QR

#==========================================
# Itty
# Moved to jan scripts/misc/qr_itty.yaml (`jan scripts misc qr_itty run`).
# Moved to jan scripts/misc/qr_itty_cat.yaml (`jan scripts misc qr_itty_cat run`).
# Moved to jan scripts/misc/to_itty.yaml (`jan scripts misc to_itty run`).

#==========================================

# `wiki` is `jan scripts misc wiki run` (existing jan script).

# URL-encode strings

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname

# cache () {
# 	local pre=""
# 	if [ ! -z "$2" ]
# 	then
#		pre="$1"
# 		shift
# 	fi
# 	local cdir=~"/cache/$pre"
# 	mkdir -pv -p "$cdir"
# 	echo "$1" >> "$cdir"/getlist
# }
# function cache_get { 
#     find ~/cache -name getlist -exec dirname {} \; | xargs -I % command wget -P ~/cache/% -nc -i ~/cache/%/getlist
# } 

# Moved to jan scripts/misc/quar.yaml (`jan scripts misc quar run`).

# Moved to jan scripts/misc/inspect.yaml (`jan scripts misc inspect run`).

# Moved to jan scripts/git/gwd.yaml (`jan scripts git gwd run`).
