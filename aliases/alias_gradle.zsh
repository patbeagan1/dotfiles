alias gw17='javaSet17 && gw'
alias gw21='javaSet21 && gw'
alias gww='gw "$(gw tasks | grep " - " | fzf -e | cut -d- -f 1 | xargs)"'
alias destroy_gradle='rm -rf ~/.gradle/caches && rm -rf .gradle && ./gradlew clean'
alias findgradle='\ps aux | grep Gradle | grep -v grep | awk '\''{print $2}'\'''
alias killgradle='findgradle | xargs kill -9'
alias gradlekill='pkill -f gradle-launcher'
alias lintBaseline='./gradlew :app:lintRelease -Dlint.baselines.continue=true'

# fzf wrapper for Gradle with a project-specific, expiring cache.
# Caches tasks for 1 week to speed up repeated use.
# Usage: Type 'gr' in your project directory and press Enter.
unalias gr # not sure where this is defined, but it's an alias for `git remote``
alias gr-clear='rm -rf "$HOME/.config/gr-wrapper"'

gr() {
    # --- 1. System & Tool Checks ---
    if ! command -v fzf &> /dev/null; then
        echo "Error: fzf is not installed." >&2
        return 1
    fi

    local gradle_cmd
    if [[ -x "./gradlew" ]]; then
        gradle_cmd="./gradlew"
    elif command -v gradle &> /dev/null; then
        gradle_cmd="gradle"
    else
        echo "Error: Could not find 'gradle' or an executable './gradlew'." >&2
        return 1
    fi

    # --- 2. Cache Configuration ---
    local cache_dir="$HOME/.config/gr-wrapper"
    local ttl=604800 # 1 week in seconds

    # Identify the project by hashing its root path (Git root or current dir)
    local project_root
    project_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)

    local project_hash
    if command -v md5sum &>/dev/null; then # Linux
        project_hash=$(echo -n "$project_root" | md5sum | awk '{print $1}')
    elif command -v md5 &>/dev/null; then # macOS
        project_hash=$(echo -n "$project_root" | md5)
    else
        echo "Error: md5 or md5sum command not found for cache hashing." >&2
        return 1
    fi

    local tasks_file="$cache_dir/${project_hash}.tasks"
    local timestamp_file="$cache_dir/${project_hash}.ts"
    mkdir -p "$cache_dir"

    # --- 3. Cache Validation ---
    local needs_update=false
    local cache_status=" (live)"
    if [[ -f "$tasks_file" && -f "$timestamp_file" && -s "$tasks_file" ]]; then
        local now last_updated age
        now=$(date +%s)
        last_updated=$(cat "$timestamp_file")
        age=$((now - last_updated))

        if (( age < ttl )); then
            # Cache is valid and fresh
            if (( age < 3600 )); then
                cache_status=" (cached $((age / 60))m ago)"
            elif (( age < 86400 )); then
                cache_status=" (cached $((age / 3600))h ago)"
            else
                cache_status=" (cached $((age / 86400))d ago)"
            fi
        else
            # Cache is stale and needs an update
            needs_update=true
            cache_status=" (stale, updating...)"
        fi
    else
        # Cache does not exist
        needs_update=true
    fi

    # --- 4. Cache Regeneration ---
    if $needs_update; then
        echo "⏳ Updating Gradle tasks cache for '$(basename "$project_root")'..." >&2
        local tasks_output
        tasks_output=$($gradle_cmd tasks --all 2>/dev/null | grep -E '^[a-zA-Z0-9]+(\S)* - ')

        if [[ -n "$tasks_output" ]]; then
            echo "$tasks_output" > "$tasks_file"
            date +%s > "$timestamp_file"
            cache_status=" (updated now)"
        else
            echo "⚠️  Failed to retrieve tasks. Using old cache if available." >&2
            if [[ ! -f "$tasks_file" ]]; then
                echo "❌ No tasks found and no cache available. Cannot proceed." >&2
                return 1
            fi
        fi
    fi

    # --- 5. FZF Selection ---
    local selected_line
    selected_line=$(cat "$tasks_file" | fzf --height 50% --min-height 20 --border \
        --prompt="Gradle > " \
        --header="Tasks for $(basename "$project_root")${cache_status}")

    # --- 6. Final Action ---
    if [[ -n "$selected_line" ]]; then
        local task
        task=$(echo "$selected_line" | awk '{print $1}')
        print -z "$gradle_cmd $task "
    fi
}

javalarge() {
    local debug=0

    # Parse flags
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--debug)
                debug=1
                set -x
                shift
                ;;
            *)
                break
                ;;
        esac
    done

    # Find all relevant processes (java, emulator, studio, Android Studio, cursor) over 50MB RSS
    local patterns="java|emulator|studio|Android Studio|cursor|gradle"
    local -a pids
    pids=()
    for pat in ${(s:|:)patterns}; do
        pids+=("${(@f)$(pgrep -f "$pat")}")
    done
    pids=("${(@u)pids}")  # Remove duplicates

    # Filter out invalid or empty PIDs (non-numeric, empty, or not running)
    local -a valid_pids
    valid_pids=()
    for pid in "${pids[@]}"; do
        if [[ "$pid" =~ '^[0-9]+$' ]] && kill -0 "$pid" 2>/dev/null; then
            valid_pids+=("$pid")
        fi
    done

    if [[ ${#valid_pids[@]} -eq 0 ]]; then
        echo "No matching processes found."
        set +x
        return
    fi

    # Gather all process info in one pass: PID, PPID, USER, %CPU, %MEM, RSS(MB), ARGS
    # (Skip vmmap/physmem here for speed)
    local header="PID      PPID     USER       %CPU   %MEM   RSSMEM  ARGS"
    local procs
    procs=$(
        for pid in "${valid_pids[@]}"; do
            # Use ps -ww to avoid truncating args, and get all info in one go
            ps -p "$pid" -o pid=,ppid=,user=,%cpu=,%mem=,rss=,args= | while read -r pid ppid user cpu mem rss args; do
                # Only print if RSS > 50MB
                if [[ "$rss" -gt 50000 ]]; then
                    if [[ $debug -eq 1 ]]; then
                        echo "DEBUG: pid=$pid, ppid=$ppid, user=$user, cpu=$cpu, mem=$mem, rss=${rss}KB, args=$args" >&2
                    fi
                    printf "%-8s %-8s %-10s %-6s %-6s %-7s %s\n" \
                        "$pid" "$ppid" "$user" "$cpu" "$mem" "$((rss/1024))MB" "$args"
                fi
            done
        done
    )

    if [[ -z "$procs" ]]; then
        echo "No matching processes over 50k found."
        set +x
        return
    fi

    # fzf selection with preview of current and parent process info, and show physmem in preview
    local selected
    selected=$(echo "$procs" | fzf --header="$header" \
        --preview='
            ppid=$(awk "{print \$2}" <<< {})
            pid=$(awk "{print \$1}" <<< {})
            ppidinfo=$(ps -p $ppid -o pid,args=)
            pidinfo=$(ps -p $pid -o pid,args=)
            width=$(( $(tput cols) ))
            echo "Parent process info:"
            echo "$ppidinfo" | fold -s -w $width
            echo
            echo "Current process info:"
            echo "$pidinfo" | fold -s -w $width
            echo
            if command -v vmmap >/dev/null 2>&1; then
                physmem=$(vmmap $pid -summary 2>/dev/null | awk "/Physical footprint:/ { print \$3 }")
                echo "Physical footprint: $physmem"
            fi
        ' \
        --preview-window=up,50%,border-sharp \
        --ansi)

    if [[ -n "$selected" ]]; then
        local pid
        pid=$(awk '{print $1}' <<< "$selected")
        # Double-check PID is valid before killing
        if [[ "$pid" =~ '^[0-9]+$' ]] && kill -0 "$pid" 2>/dev/null; then
            echo "Killing process PID: $pid"
            kill -9 "$pid"
        else
            echo "Selected PID $pid is not valid or no longer running."
        fi
    else
        echo "No process selected."
    fi

    set +x
}
