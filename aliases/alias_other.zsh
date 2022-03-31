caturl () {
	local filename="/tmp/caturl.html"  && echo "<pre>" > "$filename" && cat "$1" >> "$filename" && echo "</pre>" >> "$filename" && open /tmp/caturl.html
}
alias tk=task.py
alias tkrr='tk --read'
alias tkr='tk --read | head -15'
alias tk_today='tk -due day'
alias tkn='tk --next'

function remove_empty_lines () { cat "$1" | sed '/^[\w]*$/d'; }
function remove_empty_lines_force () { remove_empty_lines "$1" > /tmp/tmp && mv /tmp/tmp "$1" }

alias readOutLoud='say -v Moira -i -f'
alias read_out_loud=readOutLoud

alias waypoint='echo `pwd` >> ~/waypoint.txt; cat ~/waypoint.txt | sort | uniq >> /tmp/waypoint.txt; mv /tmp/waypoint.txt ~/waypoint.txt'
waypoint_go () { cd $(cat ~/waypoint.txt | fzf -1 -q "$1") ; }
alias teleport=waypoint_go
alias tp=teleport
alias savedalias='source ~/libbeagan/alias'
alias jslint='npm run lint --silent -- --frail'

alias slp='pmset sleepnow'
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
alias ps="ps -aux"
alias qp="ps auxwww|more"
alias nu="who|wc -l"
alias tulpn="netstat -tulpn"

alias note='cat >> "$(echo note-$(date +"%b%e::%T")).txt" << EOF'
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
alias jslint='npm run lint --silent -- --frail'

### AWS
# make a new bucket # aws s3 mb s3://beastey-wedding
# see all buckets # aws s3 ls
# push local files to aws # aws s3 sync engagement_full s3://beastey-wedding
