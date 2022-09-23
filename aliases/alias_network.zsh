alias q='duckduckgo.sh'
alias dns_check='systemd-resolve --status'
alias ports='netstat -vanp tcp'
alias ip_local="ipconfig getifaddr en0"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias ps-port='lsof -nP -iTCP -sTCP:LISTEN | grep'
alias psport='netstat -vanp tcp | grep 127.0.0.1'
translate-japanese() {
    local query="$(echo "$1" | sed 's/ /%20/g')"
    open -a Safari 'https://translate.google.com/?sl=en&tl=ja&op=translate&text='"$query"
}
share() {
    ssh -R 80:localhost:$1 nokey@localhost.run
}
