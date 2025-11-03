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

# Fuzzy search through history and insert the selected command on the command line (zsh only)
fzf-history-widget() {
  local selected
  selected=$(history | sed 's/^ *//g' | cut -d' ' -f3-99 | fzf --height 40% --reverse --prompt="History> ")
  if [[ -n "$selected" ]]; then
    LBUFFER+="$selected"
    zle reset-prompt
  fi
}
zle -N fzf-history-widget
bindkey '^R' fzf-history-widget


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
