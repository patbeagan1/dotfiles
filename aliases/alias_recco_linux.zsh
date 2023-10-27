# Update system packages and upgrade
alias update="sudo apt update && sudo apt upgrade"

# Clear the terminal screen
alias c="clear"

# Quickly go back to the previous directory
alias ..="cd .."

# Display open ports and associated processes
alias ports="sudo netstat -tulnp"

# Create a new directory and navigate into it
# Usage: mkd new_directory_name
mkd() {
    mkdir -p "$1" && cd "$1"
}

# Show disk space usage
alias diskspace="df -h"

# Show memory usage
alias meminfo="free -m"

# Display active processes in a user-friendly format
alias psg="ps auxf | grep -v grep | grep -i -e VSZ -e"

# Quickly extract archives based on file extension
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1        ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1       ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1     ;;
            *.tar)       tar xf $1        ;;
            *.tbz2)      tar xjf $1      ;;
            *.tgz)       tar xzf $1       ;;
            *.zip)       unzip $1     ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1    ;;
            *)           echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file!"
    fi
}

# Display public IP address
alias publicip="curl -s http://ipecho.net/plain"

# Restart networking service (useful when facing network issues)
alias restartnet="sudo systemctl restart NetworkManager"

# Open default file manager in current directory
alias explorer="xdg-open ."

# Search for a file with a specific pattern
# Usage: fsearch "filename_pattern"
fsearch() {
    find / -type f 2>/dev/null | grep "$1"
}

# Monitor system in real-time
alias monitor="htop"

# Quickly reboot the system
alias rb="sudo reboot"

# Quickly power off the system
alias off="sudo poweroff"

# Display all installed packages
alias packages="dpkg --get-selections | grep -v deinstall"

# Start a service
# Usage: sstart serviceName
alias sstart="sudo systemctl start"

# Stop a service
# Usage: sstop serviceName
alias sstop="sudo systemctl stop"

# Restart a service
# Usage: srestart serviceName
alias srestart="sudo systemctl restart"

# Reload a service (if it supports reload without dropping connections)
# Usage: sreload serviceName
alias sreload="sudo systemctl reload"

# Enable a service to start on boot
# Usage: senable serviceName
alias senable="sudo systemctl enable"

# Disable a service from starting on boot
# Usage: sdisable serviceName
alias sdisable="sudo systemctl disable"

# Check the status of a service
# Usage: sstatus serviceName
alias sstatus="sudo systemctl status"

# List all active services
alias sactive="sudo systemctl list-units --type=service --state=active"

# List all failed services
alias sfailed="sudo systemctl --failed"

# Power off the system
alias spoweroff="sudo systemctl poweroff"

# Reboot the system
alias sreboot="sudo systemctl reboot"

# Suspend the system
alias ssuspend="sudo systemctl suspend"

# Hibernate the system
alias shibernate="sudo systemctl hibernate"

# Hybrid sleep (combination of suspend and hibernate)
alias shybridsleep="sudo systemctl hybrid-sleep"

# List all timers (scheduled tasks)
alias stimers="sudo systemctl list-timers --all"

# Reload systemd, scanning for new or changed units
alias sdaemonreload="sudo systemctl daemon-reload"

# Show all logs from the current boot
alias jcurrent="sudo journalctl -b"

# Follow new log messages
alias jfollow="sudo journalctl -f"

# Show kernel logs
alias jkernel="sudo journalctl -k"

# Show logs for a specific service
# Usage: jservice serviceName
jservice() {
    sudo journalctl -u $1
}

# Display the ten most recent logs
alias jrecent="sudo journalctl -n 10"

# List current user sessions
alias llist="loginctl list-sessions"

# Show info about a specific session
# Usage: linfo sessionID
linfo() {
    loginctl show-session $1
}

# Terminate a specific user session
# Usage: lterminate sessionID
lterminate() {
    loginctl terminate-session $1
}

# Lock all current sessions
alias llockall="loginctl lock-sessions"

# Unlock all current sessions
alias lunlockall="loginctl unlock-sessions"

# Quickly reload the firewall (common when using firewalld)
alias freload="sudo firewall-cmd --reload"

# Display listening ports and their associated processes (similar to 'netstat -tulnp')
alias listening="sudo ss -tulnp"

# Display all network connections
alias allconnections="sudo ss -tuln"

