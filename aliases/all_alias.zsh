# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# Alias to enable developer options on Android devices
# Alias to enable the 'Don't keep activities' option
# Alias to disable the 'Don't keep activities' option

export P_AVD_CURRENT='Pixel_3a_API_33_arm64-v8a'
export P_PROXY_CURRENT='http://192.168.1.85:8888'
# Common ADB commands

# Shortcut for bin/adb-triage — Android crash triage helpers.

# Function to search and execute ADB commands using fzf
# Moved to jan scripts/android/androidl.yaml (`jan scripts android androidl run`).

# fzf launcher for Android Developer Options toggles via adb, grouped and colorized by action.
# Usage: Type 'adevopts' and select a toggle to apply to the current emulator/device.
# Moved to jan scripts/android/adevopts.yaml (`jan scripts android adevopts run`).

# fzf launcher for adb commands.
# Usage: Type 'afh' and press Enter.
# Moved to jan scripts/android/adb-fzf-help.yaml (`jan scripts android adb-fzf-help run`).
unalias adb-fzf-help 2>/dev/null
adb-fzf-help() { local cmd; cmd="$(jan --no-log scripts android adb-fzf-help run "$@")" && [[ -n "$cmd" ]] && print -z "$cmd"; }

# fzf launcher for Android emulators.
# Usage: Type 'avd' and press Enter to select and launch an AVD.
# Moved to jan scripts/android/emulator-fzf-help.yaml (`jan scripts android emulator-fzf-help run`).

# fzf helper for avdmanager.
# Usage: Type 'avdm' and press Enter to select an action.
# Moved to jan scripts/android/avdmanager-fzf-help.yaml (`jan scripts android avdmanager-fzf-help run`).
unalias avdmanager-fzf-help 2>/dev/null
avdmanager-fzf-help() { local cmd; cmd="$(jan --no-log scripts android avdmanager-fzf-help run "$@")" && [[ -n "$cmd" ]] && print -z "$cmd"; }

# fzf helper for sdkmanager.
# Usage: Type 'sdkm' and press Enter to select packages to install.
# Moved to jan scripts/android/sdkmanager-fzf-help.yaml (`jan scripts android sdkmanager-fzf-help run`).
unalias sdkmanager-fzf-help 2>/dev/null
sdkmanager-fzf-help() { local cmd; cmd="$(jan --no-log scripts android sdkmanager-fzf-help run "$@")" && [[ -n "$cmd" ]] && print -z "$cmd"; }
# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# duplicate `release-contains` removed; see jan script.

# Moved to jan scripts/git/release-contains.yaml (`jan scripts git release-contains run`).

# Moved to jan scripts/git/save.yaml (`jan scripts git save run`).
# Moved to jan scripts/git/switchoc.yaml (`jan scripts git switchoc run`).
# Alias for viewing the last commit in a concise format
# Alias for checking the status of the git repository
# Alias to revert a file to the version in the develop branch
# Alias to revert all files to the version in the develop branch

# Alias to list the last 10 branches
# `lb` is an extra jan name on jan/scripts/misc/last_branch.yaml (`jan alias`).
# Previously: last_branch.sh | tail -10
# Alias to list branches excluding those marked as old
# Alias to select and checkout a branch from the last 10 branches

# Alias to view the git log in a simplified format
# Alias to view the git log with more details
# Alias to view the git log with detailed formatting
# Alias to view the git log with detailed formatting and author information
# Default alias for viewing git log

# Alias for git command
# `g`, `gs`, `gb` are declared in jan/git.yaml and emitted by `jan alias`.
# Alias to push to the master branch
# Alias to check the status of the git repository
# Alias to list branches
# Alias to checkout a branch
# Function to log commits over time
# Moved to jan scripts/git/git-over-time.yaml (`jan scripts git git-over-time run`).

###########################################################
# Git Configuration
###########################################################

git config --global alias.co checkout
git config --global alias.revert-file 'checkout origin/develop --'
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.mergetest '!f(){ git merge --no-commit --no-ff "$1"; git merge --abort; echo "Merge aborted"; };f'
git config --global alias.work 'log --pretty=format:"%h%x09%an%x09%ad%x09%s"'

###########################################################
# Development
###########################################################

# Alias to get the current release version

git config --global alias.commit-ai 'git-commit-ai'
# Moved to jan scripts/git/git-commit-ai.yaml (`jan scripts git git-commit-ai run`).

# fzf wrapper to group useful git/jira/gh functions for quick access
git_tools_fzf() {
  local options=(
    "1. gh-prs-last-6-months         View your PRs from the last 6 months in this repo"
    "2. gh-prs-last-6-months-all     View your PRs from the last 6 months in multiple repos"
    "3. jirasprintmine               List your Jira issues in open sprints"
    "4. git-over-time                Show commit dates and authors"
    "5. getCurrentRelease            Show the latest release branch"
    "6. gv (git-view3)               Pretty git log graph"
    "7. gs (git status)              Show git status"
    "8. gb (git branch)              List branches"
    "9. gco (git checkout)           Checkout a branch"
    "10. lbf                         Fuzzy checkout from last 10 branches"
    "11. lbb                         Show last branch"
    "12. Exit"
  )
  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select a git/jira tool: " --height=80% --border --ansi)
  case "$choice" in
    "1."*) gh-prs-last-6-months ;;
    "2."*) 
      echo "Enter repo directories (space-separated):"
      read -r repos
      gh-prs-last-6-months-all $repos
      ;;
    "3."*) jirasprintmine ;;
    "4."*) git-over-time ;;
    "5."*) getCurrentRelease ;;
    "6."*) gv ;;
    "7."*) gs ;;
    "8."*) gb ;;
    "9."*) 
      echo "Enter branch to checkout:"
      read -r branch
      gco "$branch"
      ;;
    "10."*) lbf ;;
    "11."*) lbb ;;
    *) echo "Exiting." ;;
  esac
}

# Moved to jan scripts/git/gh-prs-last-6-months-all.yaml (`jan scripts git gh-prs-last-6-months-all run`).

# Moved to jan scripts/git/gh-prs-last-6-months.yaml (`jan scripts git gh-prs-last-6-months run`).

# Moved to jan scripts/git/gh-prs-awaiting-my-review.yaml (`jan scripts git gh-prs-awaiting-my-review run`).

# These Jira helpers now live in `gas` (single implementation), which turns a
# sprint ticket into an isolated worktree + agent window instead of an in-place
# checkout. These remain as thin wrappers for muscle memory and the gtools menu.
# Moved to jan scripts/git/jirasprintmine.yaml (`jan scripts git jirasprintmine run`).

# Moved to jan scripts/git/jirabranch.yaml (`jan scripts git jirabranch run`).

# fzf launcher for gh (GitHub CLI) commands.
# Usage: Type 'ghf' and press Enter.
# Moved to jan scripts/git/ghf.yaml (`jan scripts git ghf run`).

# fzf launcher for git commands.
# Usage: Type 'gfh' and press Enter.
# Moved to jan scripts/git/gfh.yaml (`jan scripts git gfh run`).

# Stacked PR creator using GitHub CLI
# Usage: gh-stack <base-commit-or-branch>
# Moved to jan scripts/git/gh-stack.yaml (`jan scripts git gh-stack run`).
# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
alias l.='ls -d .* --color=auto'
# `l`, `la`, `ll` are declared in jan/files.yaml and emitted by `jan alias`.
# Moved to jan scripts/files/lk.yaml (`jan scripts files lk run`).
unalias lk 2>/dev/null
lk() { local d; d="$(jan --no-log scripts files lk run "$@")" && [[ -n "$d" ]] && cd "$d"; }
# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.

# JAVA_HOME aliases live on jan/system.yaml (`macos-shell`, emitted by `jan alias`).

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum >/dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum >/dev/null || alias sha1sum="shasum"
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
# Moved to jan scripts/misc/envsec.yaml (`jan scripts misc envsec run`).
unalias envsec 2>/dev/null
envsec() {
  if [[ "$1" == load ]]; then
    eval "$(jan --no-log scripts misc envsec run "$@")"
  else
    jan --no-log scripts misc envsec run "$@"
  fi
}
# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# Moved to jan scripts/misc/waypoint_go.yaml (`jan scripts misc waypoint_go run`).
unalias waypoint_go 2>/dev/null
waypoint_go() { local d; d="$(jan --no-log scripts misc waypoint_go run "$@")" && [[ -n "$d" ]] && cd "$d"; }
# Moved to jan scripts/misc/z-cd.yaml (`jan scripts misc z-cd run`).
# `jan alias` also emits `tp` for scripts/misc/tp.yaml (PS1 helper); unalias so this cd wrapper wins.
unalias tp 2>/dev/null
tp() { local d; d="$(jan --no-log scripts misc z-cd run "$@")" && [[ -n "$d" ]] && cd "$d"; }
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
