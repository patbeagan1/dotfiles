#!/usr/bin/env bash
# agent-session: Create a new window with 2 vertical panes (for agent workflows).
# Supports worktrees, agent selection (cursor/claude), window switching via fzf,
# and prune/cleanup of worktrees. (c) 2025 Pat Beagan: MIT License

set -euo pipefail

detach=false
prompt=""
prompt_file=""
ticket=""
window_name=""
window_path=""
start_dir=""
start_branch=""
from_dir=""
worktree=false
agent="cursor"
worktree_base=""

usage() {
    cat << EOF
Usage: agent-session [OPTIONS] [NAME] [PROMPT]
       agent-session create-batch FILE [OPTIONS]
       agent-session switch
       agent-session list
       agent-session system [--purge] [--worktree-base DIR]
       agent-session system remove PATH
       agent-session prune [OPTIONS] [PATH]
       agent-session doctor [--fix]
       agent-session cleanup
       agent-session snapshot
       agent-session restore

Creates a new tmux window with 2 vertical panes (agent in top pane) and switches
to it. Worktrees created with --worktree are recorded in a registry. Window state
is snapshotted on every add/remove so it can be restored after a crash.

Options (create session):
  -h, --help       Show this help and exit
  -d, --detach     Create the window in the background and print the command to
                   switch to it later (do not change the current window)
  -n, --name NAME  Set the tmux window name (default: first positional is NAME)
  -p, --path PATH  Set path for window (alternative to -n when passing path)
  --dir DIR        Starting directory for panes (enables aliases; no need to cd)
  --from DIR       Source repo to branch the worktree from (default: --dir if it is a
                   git repo, else the current repo)
  --branch BRANCH  Branch to use (with --worktree: base branch for the new worktree)
  --worktree       Create a new worktree under the durable base with a unique branch,
                   freshly fetched + branched off origin/<branch>; use it as cwd for panes
  --agent AGENT    Agent to start: cursor (default) or claude
  --ticket ID      Ticket or issue ID/URL to associate with this window (for list/switch/prune)
  --prompt-file PATH  Read initial prompt from file (instead of positional args)
  -w, --worktree-base DIR  Base directory for worktrees
                   (default: \${XDG_STATE_HOME:-\$HOME/.local/state}/agent-session/worktrees,
                   override with \$AGENT_SESSION_WORKTREE_BASE)

Subcommands:
  create-batch FILE  Create one window per line from FILE (format: name|prompt|ticket).
                     Supports -d, --worktree, --branch, --agent (apply to all).
  switch           Use fzf to search tmux windows by ticket or title and switch
  system           List worktrees created by agent-session (location and branch).
                   --purge: remove stale registry entries.
                   remove PATH: force-remove worktree and unregister.
  prune            List worktrees and PR status (merged/closed = safe to remove).
                   --registered-only: only worktrees in the registry.
                   --force-remove: remove safe worktrees and unregister.
                   PATH: force-remove that worktree and unregister.
                   --find-by-title TITLE: find commit on develop by message.
  doctor           Reconcile on-disk state with git (tmux-independent). Prunes stale git
                   worktree metadata, removes registry/snapshot entries whose dirs are gone,
                   and re-adds agent-* worktrees git knows about but the registry doesn't.
                   Read-only by default; --fix applies removals.
  cleanup          Remove the worktree for the current window and close the window
                   (only if window was created with --worktree).
  list             List agent-session windows from snapshot with attached/orphan status.
  snapshot         Show current snapshot (all agent-session windows to be restored).
  restore          Recreate all agent-session windows from the last snapshot.
                   Run inside tmux after a crash to reinstate windows.

Examples:
  agent-session my-feature "Implement login"
  agent-session --worktree --branch develop
  agent-session system
  agent-session system remove ~/.local/state/agent-session/worktrees/repo/agent-repo-20250101-120000-1234
  agent-session prune --registered-only
  agent-session prune --force-remove
  agent-session prune ~/.local/state/agent-session/worktrees/repo/agent-repo-20250101-120000-1234
  agent-session doctor
  agent-session doctor --fix
  agent-session list
  agent-session cleanup
  agent-session snapshot
  agent-session restore

EOF
}

# --- Subcommand: switch (fzf by ticket or title) ---
cmd_switch() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required for 'agent-session switch'. Install fzf first." >&2
        exit 1
    fi
    local list
    list=$(tmux list-windows -F '#{window_index} #{window_name}' 2>/dev/null || true)
    if [[ -z "$list" ]]; then
        echo "No windows to switch to." >&2
        exit 0
    fi
    local chosen
    chosen=$(echo "$list" | fzf --no-multi --header="Switch to window (search by ticket or title)" || true)
    if [[ -n "$chosen" ]]; then
        local idx
        idx=$(echo "$chosen" | awk '{print $1}')
        tmux select-window -t ":$idx"
    fi
}

# --- Worktree helpers ---
# Resolve symlinks for an existing dir so comparisons are stable (e.g. macOS
# /tmp -> /private/tmp). Portable: no realpath/coreutils dependency. Falls back
# to the input for non-existent paths.
canon_path() {
    local p="$1"
    if [[ -d "$p" ]]; then
        (cd "$p" 2>/dev/null && pwd -P) || echo "$p"
    else
        echo "$p"
    fi
}

get_repo_name() {
    local top
    top=$(git rev-parse --show-toplevel 2>/dev/null || true)
    [[ -n "$top" ]] && basename "$top" || echo "repo"
}

get_default_branch() {
    local br
    br=$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||') || true
    [[ -n "$br" ]] && echo "$br" || echo "main"
}

# Durable base directory for new worktrees. Precedence:
#   explicit -w/--worktree-base (passed in $1) > $AGENT_SESSION_WORKTREE_BASE >
#   ${XDG_STATE_HOME:-$HOME/.local/state}/agent-session/worktrees
# Deliberately NOT /tmp: macOS clears /tmp, which deletes worktrees out from under git.
get_worktree_base() {
    local explicit="${1:-}"
    if [[ -n "$explicit" ]]; then
        echo "$explicit"
    elif [[ -n "${AGENT_SESSION_WORKTREE_BASE:-}" ]]; then
        echo "$AGENT_SESSION_WORKTREE_BASE"
    else
        echo "${XDG_STATE_HOME:-$HOME/.local/state}/agent-session/worktrees"
    fi
}

# List worktrees under a base dir that belong to the current repo
list_worktrees_under() {
    local base="$1"
    local main_repo
    main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
    [[ -z "$main_repo" ]] && return 0
    git worktree list --porcelain 2>/dev/null | while read -r line; do
        if [[ "$line" == worktree* ]]; then
            path="${line#worktree }"
            if [[ "$path" != "$main_repo" ]] && [[ -d "$path" ]] && [[ "$path" == "$base"* ]]; then
                echo "$path"
            fi
        fi
    done
}

# Count branches in a worktree (excluding default)
branch_count_in_worktree() {
    local wt="$1"
    local default="${2:-main}"
    (cd "$wt" && git branch --list --no-column 2>/dev/null | grep -v "^\*" | sed 's/^[* ]*//' | grep -v "^$default$" | wc -l)
}

# Get the single non-default branch name in worktree, or empty
single_branch_in_worktree() {
    local wt="$1"
    local default="${2:-main}"
    local branches
    branches=$(cd "$wt" && git branch --list --no-column 2>/dev/null | grep -v "^\*" | sed 's/^[* ]*//' | grep -v "^$default$" || true)
    local count
    count=$(echo "$branches" | grep -c . || echo 0)
    if [[ "$count" -eq 1 ]]; then
        echo "$branches" | head -1
    fi
}

# --- Registry (agent-session-managed worktrees) ---
# Format: path|branch|repo_toplevel|created_iso|base_branch|source_dir (one line per worktree)
# Older 4-field lines (no base_branch/source_dir) are read fine: the trailing fields
# come back empty from `IFS='|' read`.
get_registry_file() {
    echo "${AGENT_SESSION_REGISTRY:-$HOME/.config/agent-session/worktrees}"
}

registry_add() {
    local path="$1" branch="$2" repo="$3" base_branch="${4:-}" source_dir="${5:-}"
    local reg
    reg=$(get_registry_file)
    mkdir -p "$(dirname "$reg")"
    echo "${path}|${branch}|${repo}|$(date -u +%Y-%m-%dT%H:%M:%SZ)|${base_branch}|${source_dir}" >> "$reg"
}

registry_remove() {
    local path="$1"
    local reg
    reg=$(get_registry_file)
    [[ ! -f "$reg" ]] && return 0
    local tmp
    tmp=$(mktemp)
    grep -v "^${path}|" "$reg" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$reg"
}

# Output lines: path|branch|repo|created (only where path exists)
registry_list_live() {
    local reg
    reg=$(get_registry_file)
    [[ ! -f "$reg" ]] && return 0
    local line path branch repo created
    while IFS='|' read -r path branch repo created; do
        [[ -z "$path" ]] && continue
        [[ -d "$path" ]] && echo "${path}|${branch}|${repo}|${created}"
    done < "$reg"
}

registry_contains_path() {
    local path="$1"
    local reg
    reg=$(get_registry_file)
    [[ ! -f "$reg" ]] && return 1
    grep -q "^${path}|" "$reg"
}

# Output lines of worktree paths that have a tmux window with @agent-worktree set to that path
attached_worktree_paths() {
    [[ -z "${TMUX:-}" ]] && return 0
    local idx wt
    tmux list-windows -F '#{window_index}' | while read -r idx; do
        wt=$(tmux show-window-option -t ":$idx" -v @agent-worktree 2>/dev/null || true)
        [[ -n "$wt" ]] && echo "$wt"
    done
}

# --- Snapshot (persist agent-session windows for restore after crash) ---
# Format: type|worktree_path|window_name|start_dir|agent|prompt|ticket (one line per window)
# type = worktree | dir. Backward compat: lines with 5 fields have empty prompt and ticket.
get_snapshot_file() {
    echo "${AGENT_SESSION_SNAPSHOT:-$HOME/.config/agent-session/snapshot}"
}

snapshot_add() {
    local type="$1" worktree_path="$2" window_name="$3" start_dir="$4" agent="$5" prompt="$6" ticket="$7"
    local snap
    snap=$(get_snapshot_file)
    mkdir -p "$(dirname "$snap")"
    echo "${type}|${worktree_path}|${window_name}|${start_dir}|${agent}|${prompt}|${ticket}" >> "$snap"
}

snapshot_remove_by_worktree() {
    local path="$1"
    local snap
    snap=$(get_snapshot_file)
    [[ ! -f "$snap" ]] && return 0
    local tmp
    tmp=$(mktemp)
    awk -v p="$path" -F'|' '$2 != p {print}' "$snap" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$snap"
}

# --- Subcommand: restore ---
cmd_restore() {
    if [[ -z "${TMUX:-}" ]]; then
        echo "Error: Not running inside tmux. Start tmux first, then run: agent-session restore" >&2
        exit 1
    fi
    local snap
    snap=$(get_snapshot_file)
    if [[ ! -f "$snap" ]] || ! [[ -s "$snap" ]]; then
        echo "No snapshot found. Snapshot file: $snap" >&2
        exit 0
    fi
    local count=0
    local line
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local type worktree_path window_name start_dir agent prompt ticket
        type="${line%%|*}"; line="${line#*|}"
        worktree_path="${line%%|*}"; line="${line#*|}"
        window_name="${line%%|*}"; line="${line#*|}"
        start_dir="${line%%|*}"; line="${line#*|}"
        agent="${line%%|*}"; line="${line#*|}"
        prompt="${line%%|*}"; line="${line#*|}"
        ticket="$line"
        [[ -z "$type" ]] && continue
        if [[ "$type" == worktree ]]; then
            if [[ ! -d "${worktree_path:-}" ]]; then
                echo "Skipping missing worktree: $worktree_path" >&2
                continue
            fi
        fi
        local name="${window_name:-agent-$(date +%Y%m%d-%H%M%S)-$count}"
        local cwd=""
        [[ "$type" == worktree ]] && cwd="$worktree_path"
        [[ "$type" == dir ]] && cwd="$start_dir"
        tmux new-window -n "$name"
        new_window=$(tmux display-message -p '#{window_index}')
        if [[ -n "$cwd" ]]; then
            tmux send-keys -t ":$new_window" "cd $(printf '%q' "$cwd")" Enter
        fi
        case "$agent" in
            cursor) tmux send-keys -t ":$new_window" 'cursor-agent' Enter ;;
            claude) tmux send-keys -t ":$new_window" 'claude' Enter ;;
            *) tmux send-keys -t ":$new_window" 'cursor-agent' Enter ;;
        esac
        tmux split-window -t ":$new_window" -v
        if [[ -n "$cwd" ]]; then
            tmux send-keys -t ":$new_window.1" "cd $(printf '%q' "$cwd")" Enter
        fi
        if [[ "$type" == worktree ]]; then
            tmux set-window-option -t ":$new_window" @agent-worktree "$worktree_path"
        fi
        if [[ -n "$ticket" ]]; then
            tmux set-window-option -t ":$new_window" @agent-ticket "$ticket"
        fi
        if [[ -n "$prompt" ]]; then
            tmux select-pane -t ":$new_window.0"
            tmux send-keys -t ":$new_window.0" -- "$prompt"
            tmux send-keys -t ":$new_window.0" C-Enter
        fi
        ((count++)) || true
    done < "$snap"
    echo "Restored $count agent-session window(s)."
}

# --- Subcommand: snapshot (show current snapshot) ---
cmd_snapshot() {
    local snap
    snap=$(get_snapshot_file)
    if [[ ! -f "$snap" ]] || ! [[ -s "$snap" ]]; then
        echo "No snapshot. File: $snap"
        return 0
    fi
    echo "Snapshot ($snap):"
    printf "%-8s %-35s %-20s %-8s %-12s\n" "TYPE" "WORKTREE_OR_DIR" "WINDOW_NAME" "AGENT" "TICKET"
    printf "%-8s %-35s %-20s %-8s %-12s\n" "----" "---------------" "----------" "-----" "------"
    local line
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local type worktree_path window_name start_dir agent prompt ticket
        type="${line%%|*}"; line="${line#*|}"
        worktree_path="${line%%|*}"; line="${line#*|}"
        window_name="${line%%|*}"; line="${line#*|}"
        start_dir="${line%%|*}"; line="${line#*|}"
        agent="${line%%|*}"; line="${line#*|}"
        prompt="${line%%|*}"; line="${line#*|}"
        ticket="$line"
        local loc="$worktree_path"
        [[ "$type" == dir ]] && loc="$start_dir"
        printf "%-8s %-35s %-20s %-8s %-12s\n" "$type" "${loc:0:35}" "${window_name:0:20}" "$agent" "${ticket:0:12}"
    done < "$snap"
}

# --- Subcommand: list (status) ---
# Output: window name, worktree or dir, agent, ticket, attached|orphan
cmd_list() {
    local snap
    snap=$(get_snapshot_file)
    if [[ ! -f "$snap" ]] || ! [[ -s "$snap" ]]; then
        echo "No snapshot. File: $snap"
        return 0
    fi
    # Build set of current window names and worktree paths from tmux
    local -A window_names
    local -A window_worktrees
    if [[ -n "${TMUX:-}" ]]; then
        local idx name wt
        while IFS='|' read -r idx name; do
            [[ -z "$idx" ]] && continue
            window_names["$name"]=1
            wt=$(tmux show-window-option -t ":$idx" -v @agent-worktree 2>/dev/null || true)
            if [[ -n "$wt" ]]; then
                window_worktrees["$wt"]=1
            fi
        done < <(tmux list-windows -F '#{window_index}|#{window_name}')
    fi
    printf "%-20s %-38s %-8s %-12s %-8s\n" "WINDOW_NAME" "WORKTREE_OR_DIR" "AGENT" "TICKET" "STATUS"
    printf "%-20s %-38s %-8s %-12s %-8s\n" "----------" "---------------" "-----" "------" "------"
    local line
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        local type worktree_path window_name start_dir agent prompt ticket
        type="${line%%|*}"; line="${line#*|}"
        worktree_path="${line%%|*}"; line="${line#*|}"
        window_name="${line%%|*}"; line="${line#*|}"
        start_dir="${line%%|*}"; line="${line#*|}"
        agent="${line%%|*}"; line="${line#*|}"
        prompt="${line%%|*}"; line="${line#*|}"
        ticket="$line"
        local loc="$worktree_path"
        [[ "$type" == dir ]] && loc="$start_dir"
        local status="orphan"
        if [[ -n "${TMUX:-}" ]]; then
            if [[ -n "${window_names["$window_name"]:-}" ]]; then
                status="attached"
            elif [[ -n "$worktree_path" ]] && [[ -n "${window_worktrees["$worktree_path"]:-}" ]]; then
                status="attached"
            fi
        fi
        printf "%-20s %-38s %-8s %-12s %-8s\n" "${window_name:0:20}" "${loc:0:38}" "$agent" "${ticket:0:12}" "$status"
    done < "$snap"
}

# --- Subcommand: create-batch ---
# FILE format: one line per window, name|prompt|ticket (prompt and ticket optional)
cmd_create_batch() {
    local batch_file=""
    local batch_detach=""
    local batch_worktree=""
    local batch_branch_val=""
    local batch_agent_val=""
    local batch_base_val=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -d|--detach) batch_detach="-d"; shift ;;
            --worktree) batch_worktree="--worktree"; shift ;;
            --branch) batch_branch_val="${2:-}"; shift 2 ;;
            --agent) batch_agent_val="${2:-}"; shift 2 ;;
            -w|--worktree-base) batch_base_val="${2:-}"; shift 2 ;;
            -*)
                echo "Error: create-batch: unknown option $1" >&2
                exit 1
                ;;
            *)
                if [[ -z "$batch_file" ]]; then
                    batch_file="$1"
                fi
                shift
                ;;
        esac
    done
    if [[ -z "$batch_file" ]]; then
        echo "Error: create-batch requires FILE. Usage: agent-session create-batch FILE [-d] [--worktree] [--branch BR] [--agent AGENT]" >&2
        exit 1
    fi
    if [[ ! -f "$batch_file" ]]; then
        echo "Error: create-batch: file not found: $batch_file" >&2
        exit 1
    fi
    if [[ -z "${TMUX:-}" ]]; then
        echo "Error: Not running inside tmux. Run create-batch from within a tmux session." >&2
        exit 1
    fi
    local script_dir
    script_dir=$(dirname "$0")
    local agent_script
    if [[ -x "$script_dir/agent-session.sh" ]]; then
        agent_script="$script_dir/agent-session.sh"
    else
        agent_script="$0"
    fi
    local count=0
    local line name prompt ticket
    while IFS= read -r line; do
        [[ -z "$line" ]] && continue
        name="${line%%|*}"; line="${line#*|}"
        prompt="${line%%|*}"; line="${line#*|}"
        ticket="$line"
        local opts=()
        [[ -n "$batch_detach" ]] && opts+=(-d)
        [[ -n "$batch_worktree" ]] && opts+=(--worktree)
        [[ -n "$batch_branch_val" ]] && opts+=(--branch "$batch_branch_val")
        [[ -n "$batch_agent_val" ]] && opts+=(--agent "$batch_agent_val")
        [[ -n "$batch_base_val" ]] && opts+=(-w "$batch_base_val")
        opts+=(-n "$name")
        [[ -n "$ticket" ]] && opts+=(--ticket "$ticket")
        opts+=(--)
        [[ -n "$prompt" ]] && opts+=("$prompt")
        "$agent_script" "${opts[@]}"
        ((count++)) || true
    done < "$batch_file"
    echo "Created $count window(s) from $batch_file."
}

# --- Subcommand: system ---
cmd_system() {
    local purge_stale=false
    local remove_path=""
    local worktree_base_system="${worktree_base}"
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --purge) purge_stale=true; shift ;;
            --worktree-base) worktree_base_system="${2:-/tmp}"; shift 2 ;;
            remove)
                remove_path="${2:-}"
                shift 2
                ;;
            *)
                shift
                ;;
        esac
    done

    # Clear stale metadata first so listings reflect reality.
    git worktree prune 2>/dev/null || true

    if [[ -n "$remove_path" ]]; then
        # Force-remove a worktree and unregister
        remove_path=$(realpath -m "$remove_path" 2>/dev/null || echo "$remove_path")
        if [[ ! -d "$remove_path" ]]; then
            echo "Error: Path does not exist or is not a directory: $remove_path" >&2
            exit 1
        fi
        local main_repo
        main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
        if [[ -z "$main_repo" ]]; then
            echo "Error: Not in a git repository." >&2
            exit 1
        fi
        git worktree remove "$remove_path" --force 2>/dev/null || true
        snapshot_remove_by_worktree "$remove_path"
        registry_remove "$remove_path"
        echo "Removed worktree: $remove_path"
        return 0
    fi

    if [[ "$purge_stale" == true ]]; then
        local reg
        reg=$(get_registry_file)
        [[ ! -f "$reg" ]] && return 0
        local tmp
        tmp=$(mktemp)
        while IFS= read -r line; do
            path=$(echo "$line" | cut -d'|' -f1)
            [[ -d "$path" ]] && echo "$line" >> "$tmp"
        done < "$reg"
        mv "$tmp" "$reg"
        echo "Purged stale registry entries."
    fi

    # List registered worktrees with current branch and attached/orphan status
    local reg
    reg=$(get_registry_file)
    if [[ ! -f "$reg" ]] || ! [[ -s "$reg" ]]; then
        echo "No registered agent-session worktrees. Registry: $reg"
        return 0
    fi

    local -A attached_map
    local p
    while IFS= read -r p; do
        [[ -n "$p" ]] && attached_map["$p"]=1
    done < <(attached_worktree_paths)

    printf "%-50s %-30s %-12s %-10s %-8s\n" "PATH" "BRANCH" "BASE" "REPO" "STATUS"
    printf "%-50s %-30s %-12s %-10s %-8s\n" "----" "-----" "----" "----" "------"
    while IFS='|' read -r path branch repo created base_branch source_dir; do
        [[ -z "$path" ]] && continue
        if [[ ! -d "$path" ]]; then
            printf "%-50s (stale - missing)\n" "$path"
            continue
        fi
        local current_br
        current_br=$(git -C "$path" branch --show-current 2>/dev/null) || current_br="?"
        local repo_name
        repo_name=$(basename "$repo" 2>/dev/null) || repo_name="$repo"
        local status="orphan"
        [[ -n "${attached_map["$path"]:-}" ]] && status="attached"
        printf "%-50s %-30s %-12s %-10s %-8s\n" "$path" "$current_br" "${base_branch:-?}" "$repo_name" "$status"
    done < "$reg"
}

# --- Subcommand: prune ---
cmd_prune() {
    local find_by_title=""
    local force_remove=false
    local registered_only=false
    local force_remove_path=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --find-by-title) find_by_title="${2:-}"; shift 2 ;;
            --force-remove) force_remove=true; shift ;;
            --registered-only) registered_only=true; shift ;;
            --force-remove-path) force_remove_path="${2:-}"; shift 2 ;;
            *)
                if [[ -d "$1" ]] && [[ -z "$force_remove_path" ]]; then
                    force_remove_path="$1"
                    shift
                else
                    shift
                fi
                ;;
        esac
    done

    if [[ -n "$find_by_title" ]]; then
        local develop_br="develop"
        if ! git rev-parse "origin/$develop_br" &>/dev/null; then
            develop_br=$(get_default_branch)
        fi
        local commit
        commit=$(git log "origin/$develop_br" --oneline -100 --grep="$find_by_title" 2>/dev/null | head -1)
        if [[ -z "$commit" ]]; then
            commit=$(git log "$develop_br" --oneline -100 --grep="$find_by_title" 2>/dev/null | head -1)
        fi
        if [[ -n "$commit" ]]; then
            echo "Found on $develop_br: $commit"
        else
            echo "No commit matching title on $develop_br." >&2
        fi
        return 0
    fi

    # Force-remove a single path (and unregister) without PR check
    if [[ -n "$force_remove_path" ]]; then
        force_remove_path=$(realpath -m "$force_remove_path" 2>/dev/null || echo "$force_remove_path")
        if [[ ! -d "$force_remove_path" ]]; then
            echo "Error: Path does not exist or is not a directory: $force_remove_path" >&2
            exit 1
        fi
        main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
        if [[ -z "$main_repo" ]]; then
            echo "Error: Not in a git repository." >&2
            exit 1
        fi
        git worktree remove "$force_remove_path" --force 2>/dev/null || true
        snapshot_remove_by_worktree "$force_remove_path"
        registry_remove "$force_remove_path"
        echo "Removed worktree: $force_remove_path"
        return 0
    fi

    if ! command -v gh &>/dev/null && [[ "$force_remove" != true ]]; then
        echo "Warning: 'gh' not found; cannot verify PR status. Install gh CLI." >&2
    fi

    local default_br
    default_br=$(get_default_branch)
    local main_repo
    main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
    if [[ -z "$main_repo" ]]; then
        echo "Not in a git repo." >&2
        exit 1
    fi

    # Clear stale metadata so deleted worktree dirs don't linger or block branches.
    git worktree prune 2>/dev/null || true

    local worktrees
    if [[ "$registered_only" == true ]]; then
        worktrees=$(registry_list_live | awk -v main="$main_repo" -F'|' '$3 == main {print $1}')
    else
        # Empty base => all of this repo's worktrees (durable base + legacy /tmp).
        worktrees=$(list_worktrees_under "$worktree_base")
    fi
    if [[ -z "$worktrees" ]]; then
        if [[ "$registered_only" == true ]]; then
            echo "No registered worktrees found."
        else
            echo "No worktrees found for this repo${worktree_base:+ under $worktree_base}."
        fi
        return 0
    fi

    local -A prune_attached_map
    local p
    while IFS= read -r p; do
        [[ -n "$p" ]] && prune_attached_map["$p"]=1
    done < <(attached_worktree_paths)

    while IFS= read -r wt; do
        [[ -z "$wt" ]] && continue
        [[ ! -d "$wt" ]] && continue
        local count
        count=$(branch_count_in_worktree "$wt" "$default_br")
        if [[ "$count" -gt 1 ]]; then
            echo "Warning: $wt has $count non-default branches; skipping." >&2
            continue
        fi
        local br
        br=$(single_branch_in_worktree "$wt" "$default_br")
        if [[ -z "$br" ]]; then
            continue
        fi
        local state=""
        if command -v gh &>/dev/null; then
            state=$(gh pr view "$br" --json state -q .state 2>/dev/null || true)
        fi
        local wt_status="orphan"
        [[ -n "${prune_attached_map["$wt"]:-}" ]] && wt_status="attached"
        if [[ "$state" == "MERGED" ]] || [[ "$state" == "CLOSED" ]]; then
            echo "Safe to remove: $wt (branch $br, PR $state, $wt_status)"
            if [[ "$force_remove" == true ]]; then
                if [[ "$wt_status" == "attached" ]]; then
                    echo "  Warning: window still attached; skipping remove. Run cleanup in that window first." >&2
                else
                    git worktree remove "$wt" --force 2>/dev/null || true
                    snapshot_remove_by_worktree "$wt"
                    registry_remove "$wt"
                    echo "  Removed."
                fi
            fi
        else
            echo "Active: $wt (branch $br, PR state: ${state:-none}, $wt_status)"
        fi
    done <<< "$worktrees"
}

# --- Subcommand: cleanup ---
cmd_cleanup() {
    if [[ -z "${TMUX:-}" ]]; then
        echo "Error: Not running inside tmux." >&2
        exit 1
    fi
    local wt
    wt=$(tmux show-window-option -v @agent-worktree 2>/dev/null || true)
    if [[ -z "$wt" ]] || [[ ! -d "$wt" ]]; then
        echo "Current window has no associated worktree (or path missing). Closing window only." >&2
        tmux kill-window
        return 0
    fi
    local main_repo
    main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
    if [[ -z "$main_repo" ]]; then
        tmux kill-window
        return 0
    fi
    snapshot_remove_by_worktree "$wt"
    registry_remove "$wt"
    git worktree remove "$wt" --force 2>/dev/null || true
    git worktree prune 2>/dev/null || true
    tmux kill-window
}

# --- Subcommand: doctor (reconcile on-disk state with git; tmux-independent) ---
cmd_doctor() {
    local apply=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fix) apply=true; shift ;;
            *) shift ;;
        esac
    done

    local reg
    reg=$(get_registry_file)

    # Collect every repo we know about: the current repo plus each registered
    # source_dir/repo. Canonicalize so symlinked paths (/tmp vs /private/tmp) dedupe.
    # Plain newline list + sort -u (portable; no associative arrays).
    local repos_raw="" cur registered_canon=""
    cur=$(git rev-parse --show-toplevel 2>/dev/null || true)
    [[ -n "$cur" ]] && repos_raw+="$(canon_path "$cur")"$'\n'
    if [[ -f "$reg" ]]; then
        local path branch repo created base_branch source_dir
        while IFS='|' read -r path branch repo created base_branch source_dir; do
            [[ -n "$path" ]] && registered_canon+="$(canon_path "$path")"$'\n'
            [[ -n "$source_dir" ]] && [[ -d "$source_dir" ]] && repos_raw+="$(canon_path "$source_dir")"$'\n'
            [[ -n "$repo" ]] && [[ -d "$repo" ]] && repos_raw+="$(canon_path "$repo")"$'\n'
        done < "$reg"
    fi
    local repos
    repos=$(printf '%s' "$repos_raw" | sort -u | grep -v '^$' || true)

    # 1) Prune stale git worktree metadata so deleted dirs stop holding branches.
    local r repo_count=0
    while IFS= read -r r; do
        [[ -z "$r" ]] && continue
        git -C "$r" worktree prune 2>/dev/null || true
        repo_count=$((repo_count + 1))
    done <<< "$repos"
    echo "Pruned stale worktree metadata in ${repo_count} repo(s)."

    # 2) Registry/snapshot entries whose worktree dir is gone.
    local missing=0 removed=0
    if [[ -f "$reg" ]]; then
        local lines=() line p
        while IFS= read -r line; do lines+=("$line"); done < "$reg"
        for line in "${lines[@]}"; do
            [[ -z "$line" ]] && continue
            p="${line%%|*}"
            if [[ ! -d "$p" ]]; then
                missing=$((missing + 1))
                if [[ "$apply" == true ]]; then
                    registry_remove "$p"
                    snapshot_remove_by_worktree "$p"
                    echo "  removed missing: $p"
                    removed=$((removed + 1))
                else
                    echo "  MISSING (use --fix to remove): $p"
                fi
            fi
        done
    fi

    # 3) agent-* worktrees git knows about but the registry doesn't -> re-track.
    local readded=0 wt bn br
    while IFS= read -r r; do
        [[ -z "$r" ]] && continue
        while IFS= read -r wt; do
            [[ -z "$wt" ]] && continue
            [[ ! -d "$wt" ]] && continue
            bn=$(basename "$wt")
            [[ "$bn" != agent-* ]] && continue
            if ! printf '%s' "$registered_canon" | grep -Fxq "$(canon_path "$wt")"; then
                br=$(git -C "$wt" branch --show-current 2>/dev/null || true)
                if [[ "$apply" == true ]]; then
                    registry_add "$wt" "$br" "$r" "" "$r"
                    echo "  re-tracked: $wt (branch ${br:-?})"
                    readded=$((readded + 1))
                else
                    echo "  UNTRACKED (use --fix to re-track): $wt (branch ${br:-?})"
                    readded=$((readded + 1))
                fi
            fi
        done < <(git -C "$r" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}')
    done <<< "$repos"

    if [[ "$apply" == true ]]; then
        echo "Doctor: ${missing} missing removed, ${readded} re-tracked."
    else
        echo "Doctor (read-only): ${missing} missing, ${readded} untracked. Pass --fix to apply."
    fi
}

# --- Parse subcommands first ---
subcommand=""
remaining=()
for arg in "$@"; do
    case "$arg" in
        switch)
            subcommand=switch
            shift
            break
            ;;
        prune)
            subcommand=prune
            shift
            break
            ;;
        cleanup)
            subcommand=cleanup
            shift
            break
            ;;
        doctor|reconcile)
            subcommand=doctor
            shift
            break
            ;;
        system)
            subcommand=system
            shift
            break
            ;;
        restore)
            subcommand=restore
            shift
            break
            ;;
        create-batch)
            subcommand=create_batch
            shift
            break
            ;;
        list|status)
            subcommand=list
            shift
            break
            ;;
        snapshot)
            subcommand=snapshot
            shift
            break
            ;;
        *)
            remaining+=("$arg")
            shift
            ;;
    esac
done

if [[ "$subcommand" == create_batch ]]; then
    cmd_create_batch "$@"
    exit 0
fi
if [[ "$subcommand" == list ]]; then
    cmd_list
    exit 0
fi
if [[ "$subcommand" == switch ]]; then
    cmd_switch
    exit 0
fi
if [[ "$subcommand" == prune ]]; then
    cmd_prune "$@"  # subcommand already shifted off in loop
    exit 0
fi
if [[ "$subcommand" == cleanup ]]; then
    cmd_cleanup
    exit 0
fi
if [[ "$subcommand" == doctor ]]; then
    cmd_doctor "$@"
    exit 0
fi
if [[ "$subcommand" == system ]]; then
    cmd_system "$@"
    exit 0
fi
if [[ "$subcommand" == restore ]]; then
    cmd_restore
    exit 0
fi
if [[ "$subcommand" == snapshot ]]; then
    cmd_snapshot
    exit 0
fi

# --- Parse create-session options ---
args=()
i=0
while [[ $i -lt ${#remaining[@]} ]]; do
    arg="${remaining[$i]}"
    case "$arg" in
        -h|--help)
            usage
            exit 0
            ;;
        -d|--detach)
            detach=true
            ((i++)) || true
            ;;
        -n|--name)
            ((i++)) || true
            window_name="${remaining[$i]:-}"
            ((i++)) || true
            ;;
        -p|--path)
            ((i++)) || true
            window_path="${remaining[$i]:-}"
            ((i++)) || true
            ;;
        --dir)
            ((i++)) || true
            start_dir="${remaining[$i]:-}"
            ((i++)) || true
            ;;
        --from)
            ((i++)) || true
            from_dir="${remaining[$i]:-}"
            ((i++)) || true
            ;;
        --branch)
            ((i++)) || true
            start_branch="${remaining[$i]:-}"
            ((i++)) || true
            ;;
        --worktree)
            worktree=true
            ((i++)) || true
            ;;
        --agent)
            ((i++)) || true
            agent="${remaining[$i]:-cursor}"
            ((i++)) || true
            ;;
        --ticket)
            ((i++)) || true
            ticket="${remaining[$i]:-}"
            ((i++)) || true
            ;;
        --prompt-file)
            ((i++)) || true
            prompt_file="${remaining[$i]:-}"
            ((i++)) || true
            ;;
        -w|--worktree-base)
            ((i++)) || true
            worktree_base="${remaining[$i]:-/tmp}"
            ((i++)) || true
            ;;
        *)
            args+=("$arg")
            ((i++)) || true
            ;;
    esac
done

# Name is default (first positional); rest is prompt
if [[ ${#args[@]} -gt 0 ]]; then
    if [[ -z "$window_name" ]] && [[ -z "$window_path" ]]; then
        window_name="${args[0]}"
        args=("${args[@]:1}")
    fi
fi
if [[ ${#args[@]} -gt 0 ]]; then
    prompt="${args[*]}"
fi
if [[ -n "$prompt_file" ]]; then
    if [[ ! -f "$prompt_file" ]]; then
        echo "Error: --prompt-file: file not found: $prompt_file" >&2
        exit 1
    fi
    prompt=$(cat "$prompt_file")
fi

# Validate agent
case "$agent" in
    cursor|claude) ;;
    *)
        echo "Error: --agent must be 'cursor' or 'claude'." >&2
        exit 1
        ;;
esac

if [[ -z "${TMUX:-}" ]]; then
    echo "Error: Not running inside tmux. Run this script from within a tmux session." >&2
    exit 1
fi

# --- Worktree creation ---
session_cwd=""
worktree_path=""
if [[ "$worktree" == true ]]; then
    # Resolve the source repo to branch from: --from, else --dir if it's a repo, else cwd.
    source_repo=""
    for cand in "$from_dir" "$start_dir" "."; do
        [[ -z "$cand" ]] && continue
        source_repo=$(git -C "$cand" rev-parse --show-toplevel 2>/dev/null || true)
        [[ -n "$source_repo" ]] && break
    done
    if [[ -z "$source_repo" ]]; then
        echo "Error: Not in a git repository (and --from/--dir is not one). Cannot create worktree." >&2
        exit 1
    fi
    main_repo="$source_repo"
    repo_name=$(basename "$source_repo")
    default_br=$(git -C "$source_repo" rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||') || true
    [[ -z "$default_br" ]] && default_br="main"
    base_branch="${start_branch:-$default_br}"

    # Clear stale worktree metadata so deleted dirs don't keep branches "checked out".
    git -C "$source_repo" worktree prune 2>/dev/null || true
    # Best-effort fresh base so we branch off the latest remote (offline-safe).
    git -C "$source_repo" fetch origin "$base_branch" 2>/dev/null || true

    base_dir=$(get_worktree_base "$worktree_base")/"$repo_name"
    mkdir -p "$base_dir"
    # Guaranteed-unique branch name ($$ avoids same-second collisions in create-batch).
    unique_branch="agent-${repo_name}-$(date +%Y%m%d-%H%M%S)-$$"
    n=0
    while git -C "$source_repo" show-ref --verify --quiet "refs/heads/${unique_branch}"; do
        n=$((n + 1))
        unique_branch="agent-${repo_name}-$(date +%Y%m%d-%H%M%S)-$$-$n"
    done
    worktree_path="${base_dir}/${unique_branch}"

    # Always branch a fresh branch (-b) so we never get blocked by a branch checked out
    # elsewhere. Prefer origin/<base>, fall back to local <base>, then current HEAD.
    add_err=""
    if ! add_err=$(git -C "$source_repo" worktree add -b "$unique_branch" "$worktree_path" "origin/$base_branch" 2>&1); then
        if ! add_err=$(git -C "$source_repo" worktree add -b "$unique_branch" "$worktree_path" "$base_branch" 2>&1); then
            if ! add_err=$(git -C "$source_repo" worktree add -b "$unique_branch" "$worktree_path" 2>&1); then
                echo "Error: Failed to create worktree at $worktree_path (branch $unique_branch from $base_branch):" >&2
                echo "$add_err" >&2
                exit 1
            fi
        fi
    fi
    registry_add "$worktree_path" "$unique_branch" "$main_repo" "$base_branch" "$source_repo"
    session_cwd="$worktree_path"
fi

if [[ -z "$session_cwd" ]] && [[ -n "$start_dir" ]]; then
    session_cwd="$start_dir"
fi

# If detaching, remember current window
if [[ "$detach" == true ]]; then
    current_window=$(tmux display-message -p '#{window_index}')
fi

# Create new window (tmux switches to it); ensure unique name
if [[ -n "$window_name" ]]; then
    actual_window_name="$window_name"
    tmux new-window -n "$window_name"
elif [[ -n "$window_path" ]]; then
    actual_window_name=$(basename "$window_path")
    tmux new-window -n "$actual_window_name"
else
    actual_window_name="agent-$(date +%Y%m%d-%H%M%S)"
    tmux new-window -n "$actual_window_name"
fi

new_window=$(tmux display-message -p '#{window_index}')

# Store worktree path for cleanup
if [[ -n "$worktree_path" ]]; then
    tmux set-window-option -t ":$new_window" @agent-worktree "$worktree_path"
fi
# Store ticket for list/switch
if [[ -n "$ticket" ]]; then
    tmux set-window-option -t ":$new_window" @agent-ticket "$ticket"
fi

# Persist to snapshot (for restore after crash)
if [[ -n "$worktree_path" ]]; then
    snapshot_add "worktree" "$worktree_path" "$actual_window_name" "" "$agent" "$prompt" "${ticket:-}"
else
    snapshot_add "dir" "" "$actual_window_name" "${start_dir:-}" "$agent" "$prompt" "${ticket:-}"
fi

# Set cwd for new window so panes start there
if [[ -n "$session_cwd" ]]; then
    tmux send-keys -t ":$new_window" "cd $(printf '%q' "$session_cwd")" Enter
fi

# Start agent in the sole pane
case "$agent" in
    cursor) tmux send-keys -t ":$new_window" 'cursor-agent' Enter ;;
    claude) tmux send-keys -t ":$new_window" 'claude' Enter ;;
esac

if [[ -n "$prompt" ]]; then
    tmux send-keys -t ":$new_window" -- "$prompt"
fi

# Split vertically
tmux split-window -t ":$new_window" -v

if [[ -n "$session_cwd" ]]; then
    tmux send-keys -t ":$new_window.1" "cd $(printf '%q' "$session_cwd")" Enter
fi

if [[ -n "$prompt" ]]; then
    tmux select-pane -t ":$new_window.0"
    tmux send-keys -t ":$new_window.0" C-Enter
fi

if [[ "$detach" == true ]]; then
    tmux select-window -t ":$current_window"
    echo "Agent window created in background. To switch to it later:"
    echo "  tmux select-window -t :$new_window"
    echo "Or run: agent-session switch"
else
    echo "Created new window with 2 panes ($agent in top pane)."
fi
