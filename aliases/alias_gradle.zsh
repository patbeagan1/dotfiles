alias gw17='javaSet17 && gw'
alias gw21='javaSet21 && gw'
alias gww='gw "$(gw tasks | grep " - " | fzf -e | cut -d- -f 1 | xargs)"'
alias destroy_gradle='rm -rf ~/.gradle/caches && rm -rf .gradle && ./gradlew clean'
alias findgradle='\ps aux | grep Gradle | grep -v grep | awk '\''{print $2}'\'''
alias killgradle='findgradle | xargs kill -9'
alias gradlekill='pkill -f gradle-launcher'
alias lintBaseline='./gradlew :app:lintRelease -Dlint.baselines.continue=true'

javalarge() {
    set -x  # Enable debug mode

    # List all relevant processes over 500MB, show PID, RSS, COMMAND, and parent process info
    local procs

    # Expand the list of matching programs
    local patterns="java|emulator|studio|Android Studio|cursor"
    local -a pids
    # Use pgrep for each pattern and collect unique PIDs
    pids=()
    for pat in ${(s:|:)patterns}; do
        pids+=("${(@f)$(pgrep -f "$pat")}")
    done
    # Remove duplicates
    pids=("${(@u)pids}")

    if [[ ${#pids[@]} -eq 0 ]]; then
        echo "No matching processes found."
        set +x  # Disable debug mode before returning
        return
    fi

    # Build a list of process info for those over 500MB RSS
    procs=$(
        for pid in "${pids[@]}"; do
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
        echo "No matching processes over 500MB found."
        set +x  # Disable debug mode before returning
        return
    fi

    # Add header
    local header="PID      PPID     RSS(MB)    COMMAND              ARGS"
    local selected
    selected=$(echo "$procs" | fzf --header="$header" --preview='
        ppid=$(awk "{print \$2}" <<< {})
        pid=$(awk "{print \$1}" <<< {})
        # Get parent process info
        ppidinfo=$(ps -p $ppid -o pid,comm,args=)
        # Get current process info
        pidinfo=$(ps -p $pid -o pid,comm,args=)
        echo "Current process info:"
        echo "$pidinfo" | fold -s -w 30
        echo
        echo "Parent process info:"
        echo "$ppidinfo" | fold -s -w 30
    ' --ansi)

    if [[ -n "$selected" ]]; then
        local pid
        pid=$(awk '{print $1}' <<< "$selected")
        echo "Killing process PID: $pid"
        kill -9 "$pid"
    else
        echo "No process selected."
    fi

    set +x  # Disable debug mode at the end
}
