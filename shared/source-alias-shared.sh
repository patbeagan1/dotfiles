
#########################
### 3rd party service ###
#########################

alias manif="lynx -accept_all_cookies http://tldp.org/LDP/abs/html/comparison-ops.html"
alias ip_remote="curl http://ipecho.net/plain; echo"
alias ip="echo Remote/Local; ip_remote; ip_local"
alias weather="curl http://wttr.in/Boston"
alias wiki="lynx -accept_all_cookies -accept_all_cookies http://en.wikipedia.org/wiki/Special:Search?search=$(echo $@ | sed 's/ /+/g')"
alias dict="curl dict://dict.org/d:"
alias define="curl dict://dict.org/d:"
alias lynx='lynx -accept_all_cookies'

#####################
### Image Editing ###
#####################

alias convert_list_functions="convert -list"	            # list of all functions
alias convert_list="convert -list list"      	            # list of all -list options
alias convert_list_channel="convert -list channel"          # list of all image -channel options
alias convert_list_command="convert -list command"          # list of all commands
alias convert_list_color="convert -list color"              # list of all color names and values
alias convert_list_colorspace="convert -list colorspace"    # list of all -colorspace options
alias convert_list_compose="convert -list compose"          # list of all -compose options
alias convert_list_configure="convert -list configure"      # list of your IM version information
alias convert_list_decoration="convert -list decoration"    # list of all text decorations
alias convert_list_filter="convert -list filter"            # list of all -filter options
alias convert_list_font="convert -list font"                # list of all supported fonts (on your system)
alias convert_list_format="convert -list format"            # list of all image formats
alias convert_list_gravity="convert -list gravity"          # list of all -gravity positioning options
alias convert_list_primitive="convert -list primitive"      # list of all -draw primitive shapes
alias convert_list_style="convert -list style"              # list of all text styles
alias convert_list_threshold="convert -list threshold"      # list of all dither/halftone options
alias convert_list_type="convert -list type"                # list of all image types
alias convert_list_virtual="convert -list virtual-pixel"    # list of all -virtual-pixel options

alias img_resize_to_web="mogrify -resize 690\> *.png"
alias img_jpgdir_to_gif="convert -delay 20 -loop 0 *.jpg myimage.gif"

####################
### MAC specific ###
####################

alias mac_showFinderLocation='defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES && killall Finder'
alias mac_hideFinderLocation='defaults write com.apple.finder _FXShowPosixPathInTitle -bool NO && killall Finder'
alias mac_showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias mac_hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

####################
### Git specific ###
####################

alias git-view='git log --graph --simplify-by-decoration --pretty=format:%d --all'
alias git-view2='git log --graph --oneline --decorate --all'
alias git-view3="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias git-view4="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
alias gv='git-view3'

alias g="git"
alias gpom="git push origin master"
alias gs="git status"
alias gb="git branch"
alias gco="git checkout"

###################
### LS variants ###
###################

#alias ls='ls -Fh --color=auto'
# alias ll='ls -l'
alias l.='ls -d .* --color=auto'
alias l='ls -F'
alias la='ls -A'
alias lb="last_branch | tail -10"
alias lbb="last_branch | grep -v old"
alias ll="ls -lhA"
alias lla='ls -la'
alias lr='ls -ralt'
alias lsd='ls --group-directories-first'
alias lsg='ls | grep -i '
alias lsl="ls -lhFA | less"
alias lt='ls | rev | sort | rev'
alias sl="ls"
alias ralt='ls -ralt'
alias dirs="ls -al | grep '^d'"

##################
### Unix utils ###
##################

alias mkdir="mkdir -pv"

alias findempty="find . -type f -empty "
alias fhere="find . -name "

alias search=grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'

##################
### Networking ###
##################

alias ip_local="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"

### Generic ###

alias slp='pmset sleepnow'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
alias ps="ps -aux"
alias qp="ps auxwww|more"
alias nu="who|wc -l"
alias tulpn="netstat -tulpn"

alias comment=': <<EOF'
alias note='cat >> "$(echo note-$(date +"%b%e::%T")).txt" << EOF'
alias hnote='cd ~; note; cd -'
alias nscript="cat <<EOF | tee node$(date +%s).js | node"

### MISC
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
alias jslint='npm run lint --silent -- --frail'