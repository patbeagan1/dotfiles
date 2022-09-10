script-edit () { vi "$(which "$1")"; }
alias server='python3 -m http.server'
alias vpn='nordvpn status'
alias vpnc='nordvpn connect'
alias vpnd='nordvpn disconnect'
alias verify-hash='isLinux.sh && sha256sum || shasum -a 256'
alias verify-directory-contents='rsync -rvcn'

alias show-hardware-displays='sudo lshw -numeric -C display'
ipfs-upload () { ipfs files cp /ipfs/$(ipfs add -Q "$1") /"$1"; }

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
alias wgetl='wget --recursive --no-parent'
alias cache=wgetl

alias gw='./gradlew'

#==========================================
# QR
function itty () { echo -n "<pre>$1</pre>" | lzma -9 | base64 | xargs -0 printf "https://itty.bitty.site/#/%s\n"; }
function ittyqr () { qrencode -l L -v 1 -o output.png -r <(echo `itty "$1"`); }
function ittyqrc () { ittyqr "`cat $1`"; }
alias qr="qrencode -l L -v 1 -o output.png -r" 
alias qr_compileAggregate="montage output*  -geometry 120x120+1+1   montage.out.jpg"
function qr_textToImage () { qrencode -l L -v 1 -o output"$(python3 -c 'import time; print(time.time())')".png; } 


#==========================================

function wiki () { open $(wiki.js "$*") }


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
