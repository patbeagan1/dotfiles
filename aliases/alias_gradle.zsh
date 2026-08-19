# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# alias gww='./gradlew :app:assembleAlphaDebug :app:installAlphaDebug'
# alias gw17='javaSet17 && gw'
# alias gw21='javaSet21 && gw'
# alias gwt='gw "$(gw tasks | grep " - " | fzf -e | cut -d- -f 1 | xargs)"'
# alias destroy_gradle='rm -rf ~/.gradle/caches && rm -rf .gradle && ./gradlew clean'
# alias findgradle='\ps aux | grep Gradle | grep -v grep | awk '\''{print $2}'\'''
# alias killgradle='findgradle | xargs kill -9'
# alias gradlekill='pkill -f gradle-launcher'
# alias lintBaseline='./gradlew :app:lintRelease -Dlint.baselines.continue=true'

# fzf wrapper for Gradle with a project-specific, expiring cache.
# Caches tasks for 1 week to speed up repeated use.
# Usage: Type 'gr' in your project directory and press Enter.
# unalias gr # not sure where this is defined, but it's an alias for `git remote``
# alias gr-clear='rm -rf "$HOME/.config/gr-wrapper"'
#
# gr() {
#     # --- 1. System & Tool Checks ---
#     if ! command -v fzf &> /dev/null; then
#         echo "Error: fzf is not installed." >&2
#         return 1
#     fi
#
#     local gradle_cmd
#     if [[ -x "./gradlew" ]]; then
#         gradle_cmd="./gradlew"
#     elif command -v gradle &> /dev/null; then
#         gradle_cmd="gradle"
#     else
#         echo "Error: Could not find 'gradle' or an executable './gradlew'." >&2
#         return 1
#     fi
#
#     # --- 2. Cache Configuration ---
#     local cache_dir="$HOME/.config/gr-wrapper"
#     local ttl=604800 # 1 week in seconds
#
#     # Identify the project by hashing its root path (Git root or current dir)
#     local project_root
#     project_root=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
#
#     local project_hash
#     if command -v md5sum &>/dev/null; then # Linux
#         project_hash=$(echo -n "$project_root" | md5sum | awk '{print $1}')
#     elif command -v md5 &>/dev/null; then # macOS
#         project_hash=$(echo -n "$project_root" | md5)
#     else
#         echo "Error: md5 or md5sum command not found for cache hashing." >&2
#         return 1
#     fi
#
#     local tasks_file="$cache_dir/${project_hash}.tasks"
#     local timestamp_file="$cache_dir/${project_hash}.ts"
#     mkdir -p "$cache_dir"
#
#     # --- 3. Cache Validation ---
#     local needs_update=false
#     local cache_status=" (live)"
#     if [[ -f "$tasks_file" && -f "$timestamp_file" && -s "$tasks_file" ]]; then
#         local now last_updated age
#         now=$(date +%s)
#         last_updated=$(cat "$timestamp_file")
#         age=$((now - last_updated))
#
#         if (( age < ttl )); then
#             # Cache is valid and fresh
#             if (( age < 3600 )); then
#                 cache_status=" (cached $((age / 60))m ago)"
#             elif (( age < 86400 )); then
#                 cache_status=" (cached $((age / 3600))h ago)"
#             else
#                 cache_status=" (cached $((age / 86400))d ago)"
#             fi
#         else
#             # Cache is stale and needs an update
#             needs_update=true
#             cache_status=" (stale, updating...)"
#         fi
#     else
#         # Cache does not exist
#         needs_update=true
#     fi
#
#     # --- 4. Cache Regeneration ---
#     if $needs_update; then
#         echo "⏳ Updating Gradle tasks cache for '$(basename "$project_root")'..." >&2
#         local tasks_output
#         tasks_output=$($gradle_cmd tasks --all 2>/dev/null | grep -E '^[a-zA-Z0-9]+(\S)* - ')
#
#         if [[ -n "$tasks_output" ]]; then
#             echo "$tasks_output" > "$tasks_file"
#             date +%s > "$timestamp_file"
#             cache_status=" (updated now)"
#         else
#             echo "⚠️  Failed to retrieve tasks. Using old cache if available." >&2
#             if [[ ! -f "$tasks_file" ]]; then
#                 echo "❌ No tasks found and no cache available. Cannot proceed." >&2
#                 return 1
#             fi
#         fi
#     fi
#
#     # --- 5. FZF Selection ---
#     local selected_line
#     selected_line=$(cat "$tasks_file" | fzf --height 50% --min-height 20 --border \
#         --prompt="Gradle > " \
#         --header="Tasks for $(basename "$project_root")${cache_status}")
#
#     # --- 6. Final Action ---
#     if [[ -n "$selected_line" ]]; then
#         local task
#         task=$(echo "$selected_line" | awk '{print $1}')
#         print -z "$gradle_cmd $task "
#     fi
# }

# Moved to jan scripts/android/javalarge.yaml (`jan scripts android javalarge run`).
