alias gw17='javaSet17 && gw'
alias gw21='javaSet21 && gw'
alias gww='gw "$(gw tasks | grep " - " | fzf -e | cut -d- -f 1 | xargs)"'
alias destroy_gradle='rm -rf ~/.gradle/caches && rm -rf .gradle && ./gradlew clean'
alias findgradle='\ps aux | grep Gradle | grep -v grep | awk '\''{print $2}'\'''
alias killgradle='findgradle | xargs kill -9'
alias gradlekill='pkill -f gradle-launcher'
alias lintBaseline='./gradlew :app:lintRelease -Dlint.baselines.continue=true'

javalarge() {
    exit 1 # untested
    set -x  # Enable debug mode

    # List all java-related processes over 500MB, show PID, RSS, COMMAND, and parent process info
    local procs

    # Use pgrep to get all PIDs with 'java' in the command line, then ps to get info
    # This is more reliable than grepping ps output, as it avoids missing processes due to truncation or grep quirks
    local pids
    pids=$(pgrep -f java)
    if [[ -z "$pids" ]]; then
        echo "No java processes found."
        set +x  # Disable debug mode before returning
        return
    fi

    # Build a list of process info for those over 500MB RSS
    procs=$(
        for pid in $pids; do
            # Get process info: pid, ppid, rss, comm, args
            # Use ps -ww to avoid truncating args
            ps -p "$pid" -o pid=,ppid=,rss=,comm=,args= | while read -r pid ppid rss comm args; do
                echo "DEBUG: pid=$pid, ppid=$ppid, rss=${rss}KB, comm=$comm, args=$args" >&2
                if [[ "$rss" -gt 500000 ]]; then
                    printf "%-8s %-8s %-10s %-20s %s\n" "$pid" "$ppid" "$((rss/1024))MB" "$comm" "$args"
                fi
            done
        done
    )

    if [[ -z "$procs" ]]; then
        echo "No java processes over 500MB found."
        set +x  # Disable debug mode before returning
        return
    fi

    # Add header
    local header="PID      PPID     RSS(MB)    COMMAND              ARGS"
    local selected
    selected=$(echo "$procs" | fzf --header="$header" --preview='ppid=$(awk "{print \$2}" <<< {}); ppidinfo=$(ps -p $ppid -o pid,comm,args=); echo "Parent process info:\n$ppidinfo"' --ansi)

    if [[ -n "$selected" ]]; then
        local pid
        pid=$(awk '{print $1}' <<< "$selected")
        echo "Killing java process PID: $pid"
        kill -9 "$pid"
    else
        echo "No process selected."
    fi

    set +x  # Disable debug mode at the end
}
