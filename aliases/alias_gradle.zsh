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

    # Find all relevant processes (java, emulator, studio, Android Studio, cursor) over 50MB RSS
    local patterns="java|emulator|studio|Android Studio|cursor"
    local -a pids
    pids=()
    for pat in ${(s:|:)patterns}; do
        pids+=("${(@f)$(pgrep -f "$pat")}")
    done
    pids=("${(@u)pids}")  # Remove duplicates

    if [[ ${#pids[@]} -eq 0 ]]; then
        echo "No matching processes found."
        set +x
        return
    fi

    # Gather all process info in one pass: PID, PPID, USER, %CPU, %MEM, RSS(MB), COMMAND, ARGS
    local header="PID      PPID     USER       %CPU   %MEM   RSSMEM  PHYSMEM COMMAND              ARGS"
    local procs
    procs=$(
        for pid in "${pids[@]}"; do
            # Use ps -ww to avoid truncating args, and get all info in one go
            ps -p "$pid" -o pid=,ppid=,user=,%cpu=,%mem=,rss=,comm=,args= | while read -r pid ppid user cpu mem rss comm args; do
                physmem=$(vmmap $pid -summary 2>/dev/null | awk '/Physical footprint:/ { print $3 }')
                echo "DEBUG: pid=$pid, ppid=$ppid, user=$user, cpu=$cpu, mem=$mem, physmem=$physmem, rss=${rss}KB, comm=$comm, args=$args" >&2
                if [[ "$rss" -gt 50000 ]]; then
                    printf "%-8s %-8s %-10s %-6s %-6s %-7s %-7s %-20s %s\n" \
                        "$pid" "$ppid" "$user" "$cpu" "$mem" "$((rss/1024))MB" "$physmem" "$comm" "$args"
                fi
            done
        done
    )

    if [[ -z "$procs" ]]; then
        echo "No matching processes over 50k found."
        set +x
        return
    fi

    # fzf selection with preview of current and parent process info
    local selected
    selected=$(echo "$procs" | fzf --header="$header" \
        --preview='
            ppid=$(awk "{print \$2}" <<< {})
            pid=$(awk "{print \$1}" <<< {})
            ppidinfo=$(ps -p $ppid -o pid,comm,args=)
            pidinfo=$(ps -p $pid -o pid,comm,args=)
            width=$(( $(tput cols) ))
            echo "Current process info:"
            echo "$pidinfo" | fold -s -w $width
            echo
            echo "Parent process info:"
            echo "$ppidinfo" | fold -s -w $width
        ' \
        --preview-window=up,50%,border-sharp \
        --ansi)

    if [[ -n "$selected" ]]; then
        local pid
        pid=$(awk '{print $1}' <<< "$selected")
        echo "Killing process PID: $pid"
        kill -9 "$pid"
    else
        echo "No process selected."
    fi

    set +x
}
