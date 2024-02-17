alias mkdir="mkdir -pv"
alias cpv='rsync -ah --info=progress2' # use like cp, but with a progress bar
alias findempty="find . -type f -empty "
alias fhere="find . -name "
alias herefile='cat << EOF >>'
alias comment=': <<EOF'
alias strictmode='set -euo pipefail'
alias search=grep
alias grep='grep --color=auto'
alias egrep='egrep --color=auto'
alias fgrep='fgrep --color=auto'
alias psg="ps aux | grep -v grep | grep -i -e VSZ -e"
alias num_users="who | wc -l"
if isLinux.sh; then
    alias ps="ps -aux"
    alias qp="ps auxwww|more"
    alias tulpn="netstat -tulpn"
fi

editfile () { 
	local filename="$(ag -g "$1" | fzf)"; 
	if [ -z "$filename" ] ; then 
		echo "No files to edit."
		return ; 
	else 
		vi "$filename"  ; 
	fi
}      

alias trim="awk '{$1=$1;print}'"
function hrun() {
	local currCommand="$(
		history |
	       	sed 's|^ *||' |
	       	sort -r |
	       	cut -d' ' -f2-99 |
		awk '{$1=$1;print}' |
	       	fzf --no-sort -e
	)"
	echo "$currCommand"
	echo "^ command that will be run. Press enter to continue, or ctrl-c to exit."
	eval "$currCommand"
}


