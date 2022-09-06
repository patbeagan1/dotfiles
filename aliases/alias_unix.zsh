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
alias nu="who|wc -l"
if isLinux.sh; then
    alias ps="ps -aux"
    alias qp="ps auxwww|more"
    alias tulpn="netstat -tulpn"
fi
