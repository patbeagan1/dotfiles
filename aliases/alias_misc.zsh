alias gemini-cli='npx https://github.com/google-gemini/gemini-cli'

function prettyCSV() { cat "$1" | column -t -s ","; }
alias shrink_mov_from='ffmpeg -vcodec libx264 -crf 20 output.mp4 -i'

# foreach-line; do echo "$line"; done < alias
alias foreach-line='while IFS= read -r line'

alias ls-files-by-size='ls -l | tr -s " " | cut -d" " -f 5-100 | sort -n | trim.sh'
color-describe () { open "https://www.2020colours.com/$1"; }
alias nix-install='nix-env -iA nixpkgs.'

alias ntagas='tagger.py -s n tagas'
alias ntagcheck='tagger.py -s n tagcheck'
alias tagas='tagger.py tagas'
alias xnode='node -e'
alias xpython='python -c'
alias tagcheck='tagger.py tagcheck'

alias docker_check_vm='docker run -it --rm --privileged --pid=host justincormack/nsenter1'

alias kotlin_conversion='echo $((100-(100*$(ag -g ".*.java$" | wc -l)/$(ag -g ".*.kt$" | wc -l))))%'
script-edit () { vi "$(which "$1")"; }
alias server='python3 -m http.server'


# Nordvpn
alias vpn='nordvpn status; nordvpn'
alias vpnc='nordvpn connect'
alias vpnm='nordvpn mesh'
alias vpnd='nordvpn disconnect'
# fzf launcher for the nordvpn CLI.
# Usage: Type 'nv' and press Enter.
nv() {
  # Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v nordvpn &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'nordvpn' to be installed." >&2
    return 1
  fi

  # Extract subcommands from the help text.
  # The awk command now handles aliases by taking the first field (e.g., "connect,")
  # and removing the comma and any characters that follow it.
  local selected_command
  selected_command=$(nordvpn --help | grep -E '^\s+[a-z-]+' |
    awk '{sub(/,.*/, "", $1); print $1}' |
    fzf --height 80% --min-height 15 --border --prompt="NordVPN > " \
        --preview='nordvpn {} --help' \
        --preview-window='right,65%,border-left')

  # If a command was selected (the user didn't cancel),
  # place it in the command-line buffer for editing.
  if [[ -n "$selected_command" ]]; then
    print -z "nordvpn ${selected_command} "
  fi
}

alias verify-hash='is-test system os linux && sha256sum || shasum -a 256'
alias verify-directory-contents='rsync -rvcn'

alias show-hardware-displays='sudo lshw -numeric -C display'
ipfs-upload () { ipfs files cp /ipfs/$(ipfs add -Q "$1") /"$1"; }
unpin_all() { ipfs pin ls --type recursive | cut -d' ' -f1 | xargs -n1 ipfs pin rm ;}

function manu() { man -t "$1" | open -fa Preview; }

# Simple encryption and decryption
alias encrypt='gpg -c'
alias decrypt='gpg -d'

alias track-script-usage='trackusage.sh -a'

# Does the same thing as `find . -name` but faster.
alias find_filenames_matching='ag -g' 
alias findname='find . -name'

# caching web pages for offline viewing
# esp for gutenburg
alias wget-all='wget --recursive --no-parent'
alias wget-local='wget -E -H -k -K -p'
alias wget-site='wget -c -EHkKp -P sites -t 1'
alias cat-web='wget -O-'

alias gw='./gradlew'

caturl () {
	local filename="/tmp/caturl.html"  && echo "<pre>" > "$filename" && cat "$1" >> "$filename" && echo "</pre>" >> "$filename" && open /tmp/caturl.html
}

alias jslint='npm run lint --silent -- --frail'

alias slp='command -v is-test >/dev/null || { echo "is-test not installed, please install it."; return 1; }; is-test system os mac && pmset sleepnow || systemctl suspend'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


#===========================
# Notes
alias n=note
alias note='cat >> "$(echo ~/note-$(date +"%b%e::%T")).txt" << EOF'
alias hnote='cd ~; note; cd -'
alias nscript='cat <<EOF | tee node$(date +%s).js | node'

alias mnt='mount | grep -E ^/dev | column -t'
alias jam='java -jar '
alias h="history"
alias week='date +%V'
alias dush="du -sh"
alias bcommit_hist='history | grep bcommit'
alias fuck='eval $(thefuck $(fc -ln -1)); history -r'
alias jc="j c"
alias ks="kotlinc-jvm"
alias vi-raw='vi -u NONE'
alias wget="wget -c"
alias histg="history | grep"
alias historyg="history | grep"
alias jslint='npm run lint --silent -- --frail'

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

alias random="random.sh"
alias random_temp_file='/tmp/$(date +%s)_$(random 1000)'
alias d2="random 2"
alias d4="random 4"
alias d6="random 6"
alias d8="random 8"
alias d10="random 10"
alias d12="random 12"
alias d20="random 20"

#==========================================
# QR
alias qr="qrencoder.sh" 
alias qr_compileAggregate="montage /tmp/qr-output* -geometry 120x120+1+1 montage.out.jpg"
alias qr_address='qr "http://`pretty_ip -f0`"'

#==========================================
# Itty
function qr_itty () { qr $(itty.sh "$1"); }
function qr_itty_cat () { qr_itty "`cat $1`"; }
function to_itty() { cat /dev/stdin | lzma -9 | base64 -w0 | xargs -0 printf "https://itty.bitty.site/#/%s\n"; }    

#==========================================

alias to_clipboard="xclip -selection clipboard" 

function wiki () { open $(wiki.js "$*") }
alias record='asciinema rec'

alias sequence_diagram='open http://www.plantuml.com/plantuml/uml/'
alias dns_emu='for i in $(emulator -list-avds); do echo emulator -avd "$i" -netdelay none -netspeed full -dns-server 8.8.8.8; done'

alias reset_branch='git diff --name-only origin/dev | cat | xargs -I % git checkout origin/dev -- %'
alias backup_myhome='rsync -aPzv --checksum --remove-source-files --exclude="~/Downloads/MyHome/BIG" --exclude="~/Downloads/MyHome/bin" ~/Downlaods/MyHome /Volumes/home | tee backup_out.log'


# URL-encode strings
alias urlencode='python -c "import sys, urllib as ul; print ul.quote_plus(sys.argv[1]);"'

# Intuitive map function
# For example, to list all directories that contain a certain file:
# find . -name .gitattributes | map dirname
alias map="xargs -n1"

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

function quar { mv "$1" ~/.j/; }
alias tagcheck='tagger.py tagcheck'

alias g1='git log --pretty=oneline'

function inspect () { cat "$(which "$1")"; }
alias i='inspect'


function gwd() {
    # Usage: gwd <new-branch-name>
    if [ -z "$1" ]; then
        echo "Error: Please provide a name for the new worktree/branch."
        return 1
    fi

    local branch_name="$1"
    local new_dir="../$branch_name"

    # Early safety: check for uncommitted changes in the current repo
    if [[ -n "$(git status --porcelain)" ]]; then
        echo "⚠️  Warning: You have uncommitted changes in the current repository. Please commit, stash, or discard them before proceeding."
        return 1
    fi

    # Early safety: refuse to proceed if destination dir already exists
    if [[ -e "$new_dir" ]]; then
        echo "⚠️  Directory '$new_dir' already exists. Please remove it or choose a different branch name."
        return 1
    fi

    # 1. Update remote refs to ensure origin/develop is fresh
    echo "🔄 Fetching latest from origin..."
    git fetch origin develop
    if [[ $? -ne 0 ]]; then
        echo "❌ Error: 'git fetch origin develop' failed."
        return 1
    fi

    # Early return if the branch already exists
    if git show-ref --verify --quiet "refs/heads/$branch_name"; then
        echo "⚠️  Branch '$branch_name' already exists. Please choose a different name."
        return 1
    fi

    # 2. Create worktree based explicitly on origin/develop
    #    (This creates the folder and the branch simultaneously)
    if ! git worktree add -b "$branch_name" "$new_dir" origin/develop; then
        echo "❌ Error: Failed to create worktree for branch '$branch_name'."
        return 1
    fi

    # 3. Enter the new directory
    if ! pushd "$new_dir" > /dev/null; then
        echo "❌ Error: Failed to enter new worktree directory '$new_dir'."
        return 1
    fi

    # 4. Push the new branch and set the upstream to origin
    echo "🚀 Setting upstream origin/$branch_name..."
    if ! git push --set-upstream origin "$branch_name"; then
        echo "❌ Error: Failed to push and set upstream for branch '$branch_name'."
        popd > /dev/null
        return 1
    fi

    # Try to guess the Jira ticket key from the branch name ("ABC-123" pattern)
    if [[ "$branch_name" =~ ([A-Z][A-Z0-9]+-[0-9]+) ]]; then
        ticket_key="${BASH_REMATCH[1]}"
        echo "🔗 Found Jira ticket key: $ticket_key"

        # Get Jira instance subdomain from cache or prompt (reuse infrastructure)
        jira_subdomain_file="$HOME/.jira_instance_subdomain"
        JIRA_INSTANCE_SUBDOMAIN=""
        if [[ -f "$jira_subdomain_file" ]]; then
            JIRA_INSTANCE_SUBDOMAIN=$(<"$jira_subdomain_file")
        fi
        if [[ -z "$JIRA_INSTANCE_SUBDOMAIN" ]]; then
            read "JIRA_INSTANCE_SUBDOMAIN?Enter your Jira instance subdomain (the part before .atlassian.net): "
            if [[ -z "$JIRA_INSTANCE_SUBDOMAIN" ]]; then
                echo "⚠️  Jira instance subdomain is required. Skipping ticket metadata prompt."
            else
                echo "$JIRA_INSTANCE_SUBDOMAIN" > "$jira_subdomain_file"
            fi
        fi

        # Fetch ticket details using acli (accepts JIRA_INSTANCE_SUBDOMAIN in env)
        if [[ -n "$JIRA_INSTANCE_SUBDOMAIN" ]]; then
            jira_json=$(JIRA_INSTANCE_SUBDOMAIN="$JIRA_INSTANCE_SUBDOMAIN" acli jira workitem view "$ticket_key" -f 'summary,description' 2>/dev/null)
            ticket_description=$(echo "$jira_json")

            if [[ -n "$ticket_description" ]]; then
                # Run cursor-agent with the ticket content as a prompt
                echo -e "Jira Ticket Description:\n$ticket_description\n" | cursor-agent -p
            fi
        fi
    fi

    # 5. Open Cursor in the current directory
    cursor .

    # 6. Return to the original directory
    popd > /dev/null
}
