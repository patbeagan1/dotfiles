#!/usr/bin/env bash
# gas (agent-session): Create a new window with 2 vertical panes (for agent workflows).
# Supports worktrees, agent selection (cursor/claude), window/worktree/branch switching
# via fzf, and prune/cleanup of worktrees. (c) 2025 Pat Beagan: MIT License

set -euo pipefail

# Name this command is invoked as (gas by default), used in help/usage text.
prog="$(basename "$0")"

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
# Empty => resolve from persistent config (prompting once if unset). An explicit
# --agent value (cursor/claude alias or any literal command) overrides.
agent=""
worktree_base=""
open_worktree=""

usage() {
    cat << EOF
Usage: ${prog} new [OPTIONS] [NAME] [PROMPT]   (create a window; alias: create)
       ${prog} dev NAME [PROMPT]        # shortcut: new --worktree --branch develop -n NAME
       ${prog} create-batch FILE [OPTIONS]
       ${prog} switch
       ${prog} pick
       ${prog} branches
       ${prog} status [--branch BRANCH] [--fetch] [PATH]
       ${prog} config [harness-command [VALUE]]
       ${prog} list
       ${prog} system [--purge] [--worktree-base DIR]
       ${prog} system remove PATH
       ${prog} prune [OPTIONS] [PATH]
       ${prog} doctor [--fix]
       ${prog} cleanup
       ${prog} snapshot
       ${prog} restore

Creates a new tmux window with 2 vertical panes (agent in top pane) and switches
to it. Worktrees created with --worktree are recorded in a registry. Window state
is snapshotted on every add/remove so it can be restored after a crash.

Running with no arguments (or an unrecognized command/parameter) prints this help;
unrecognized input exits non-zero. Use 'new' to create a window.

Options (create session, i.e. '${prog} new [OPTIONS] [NAME] [PROMPT]'):
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
  --agent AGENT    Agent/harness to start: 'cursor' (=> cursor-agent), 'claude', or any
                   literal command. If omitted, uses the per-machine configured harness
                   command (\$AGENT_SESSION_HARNESS_COMMAND, else '${prog} config', else
                   you're prompted once and the answer is saved).
  --ticket ID      Ticket or issue ID/URL to associate with this window (for list/switch/prune)
  --prompt-file PATH  Read initial prompt from file (instead of positional args)
  --open-worktree PATH  Open a window on an EXISTING worktree path (does not create
                   a new worktree); used internally by 'pick' and 'branches'
  -w, --worktree-base DIR  Base directory for worktrees
                   (default: \${XDG_STATE_HOME:-\$HOME/.local/state}/agent-session/worktrees,
                   override with \$AGENT_SESSION_WORKTREE_BASE)

Subcommands:
  new (create)     Create a new tmux window (the create-session options above).
                   [OPTIONS] [NAME] [PROMPT] — this is the original default behavior.
  dev NAME [PROMPT]  Shortcut for the most common case: create a worktree off the
                   'develop' branch named NAME (equivalent to
                   '${prog} new --worktree --branch develop -n NAME [PROMPT]'). Extra
                   flags after NAME are forwarded (e.g. --agent claude). Override the
                   base branch with \$AGENT_SESSION_DEV_BRANCH.
  create-batch FILE  Create one window per line from FILE (format: name|prompt|ticket).
                     Supports -d, --worktree, --branch, --agent (apply to all).
  switch           Use fzf to search tmux windows by ticket or title and switch
  pick             fzf picker over worktrees. Preview shows full state
                   (git status, ahead/behind, remote-deleted, merged, PR via gh).
                   Enter switches to the live window, or opens a new one for orphans.
                   ctrl-a opens an actions menu for the highlighted row (open/switch,
                   update from develop, fetch, open PR, copy path, remove worktree).
  branches         fzf picker over git branches (local + remote-only). Enter switches
                   to / opens a worktree for the chosen branch. Same rich preview.
                   ctrl-a opens the same actions menu (worktree-only actions appear
                   once the branch has a worktree).
  status           Print the full state of a worktree/branch (used as the picker
                   preview). Args: [--branch BRANCH] [--fetch] [PATH] (PATH '-' or
                   empty = cwd). --fetch contacts origin for live remote/merged state
                   (slower); 'pick' passes it so its preview reflects the real remote.
  config           Show or set persistent per-machine config. 'config' lists it;
                   'config harness-command' shows the harness command; 'config
                   harness-command CMD' sets it (e.g. cursor-agent or claude).
  system           List worktrees created by ${prog} (location and branch).
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
  list             List ${prog} windows from snapshot with attached/orphan status.
  snapshot         Show current snapshot (all ${prog} windows to be restored).
  restore          Recreate all ${prog} windows from the last snapshot.
                   Run inside tmux after a crash to reinstate windows.

Examples:
  ${prog} dev my-feature "Implement login"
  ${prog} new my-feature "Implement login"
  ${prog} new --worktree --branch develop
  ${prog} pick
  ${prog} branches
  ${prog} status ~/.local/state/agent-session/worktrees/repo/agent-repo-...
  ${prog} system
  ${prog} prune --registered-only
  ${prog} prune --force-remove
  ${prog} doctor --fix
  ${prog} list
  ${prog} cleanup
  ${prog} restore

EOF
}

# --- Persistent config (key=value lines) ---
# Stores per-machine settings such as the harness command to launch (cursor-agent
# on some machines, claude on others). Lives beside the registry/snapshot under
# ~/.config/agent-session; override with $AGENT_SESSION_CONFIG.
get_config_file() {
    echo "${AGENT_SESSION_CONFIG:-$HOME/.config/agent-session/config}"
}

config_get() {
    local key="$1" file
    file=$(get_config_file)
    [[ -f "$file" ]] || return 0
    # Last assignment wins; tolerate no-match under set -euo pipefail.
    grep -E "^${key}=" "$file" 2>/dev/null | tail -1 | cut -d= -f2- || true
}

config_set() {
    local key="$1" value="$2" file tmp
    file=$(get_config_file)
    mkdir -p "$(dirname "$file")"
    # Write the temp beside the target (same filesystem => atomic mv, no mktemp/
    # TMPDIR dependency).
    tmp="${file}.tmp.$$"
    if [[ -f "$file" ]]; then
        grep -vE "^${key}=" "$file" > "$tmp" 2>/dev/null || true
    fi
    echo "${key}=${value}" >> "$tmp"
    mv "$tmp" "$file"
}

# Config key + env override for the harness command (the program launched in the
# agent pane).
HARNESS_KEY="harness_command"

# Prompt (on the controlling terminal) for the harness command and echo it. Errors
# to stderr and returns non-zero when there is no usable terminal to prompt on
# (writing the prompt to /dev/tty is the probe — covers detached/cron/pipe cases).
prompt_harness_command() {
    if ! printf 'Agent/harness command to launch on this machine [cursor-agent]: ' > /dev/tty 2>/dev/null; then
        echo "Error: harness command is not configured and there is no terminal to prompt on." >&2
        echo "Set it once with: ${prog} config harness-command <cmd>   (e.g. cursor-agent or claude)" >&2
        return 1
    fi
    local ans=""
    IFS= read -r ans < /dev/tty || true
    [[ -z "$ans" ]] && ans="cursor-agent"
    printf '%s' "$ans"
}

# Resolve the configured default harness command: env > config > prompt (persisted).
get_or_prompt_harness_command() {
    local cmd="${AGENT_SESSION_HARNESS_COMMAND:-}"
    [[ -z "$cmd" ]] && cmd=$(config_get "$HARNESS_KEY")
    if [[ -z "$cmd" ]]; then
        cmd=$(prompt_harness_command) || return 1
        [[ -n "$cmd" ]] && config_set "$HARNESS_KEY" "$cmd"
    fi
    printf '%s' "$cmd"
}

# Map an agent label to the command to launch. 'cursor'/'claude' are built-in
# aliases; any other non-empty value is treated as a literal command; empty
# consults the persistent config (prompting + saving on first use).
resolve_agent_command() {
    local label="$1"
    case "$label" in
        cursor) echo "cursor-agent" ;;
        claude) echo "claude" ;;
        "")      get_or_prompt_harness_command ;;
        *)       echo "$label" ;;
    esac
}

# --- Subcommand: config ---
cmd_config() {
    local key="${1:-}" value="${2:-}"
    case "$key" in
        ""|list|show)
            local file
            file=$(get_config_file)
            echo "Config file: $file"
            if [[ -f "$file" ]] && [[ -s "$file" ]]; then
                cat "$file"
            else
                echo "(empty)"
            fi
            ;;
        harness-command|harness_command)
            if [[ -n "$value" ]]; then
                config_set "$HARNESS_KEY" "$value"
                echo "Set ${HARNESS_KEY} = $value"
            else
                local cur
                cur=$(config_get "$HARNESS_KEY")
                echo "${HARNESS_KEY} = ${cur:-<unset>}"
            fi
            ;;
        *)
            echo "Usage: ${prog} config [harness-command [VALUE]]" >&2
            exit 1
            ;;
    esac
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

# Absolute path to the command that invoked us, so fzf --preview (run in a fresh
# shell) and recursive re-invocations can reference it reliably regardless of the
# name it is installed under (gas, agent-session.sh, a custom symlink, ...).
resolve_self() {
    local s="$0"
    case "$s" in
        /*) ;;                                              # already absolute
        */*) s="$(cd "$(dirname "$s")" 2>/dev/null && pwd -P)/$(basename "$s")" ;;
        *) s="$(command -v "$s" 2>/dev/null || echo "$s")" ;;  # bare name on PATH
    esac
    echo "$s"
}

# --- Subcommand: status (rich per-worktree/branch state; also fzf --preview) ---
# Usage: gas status [--branch BRANCH] [--fetch] [PATH]
# --fetch contacts origin for live remote-existence/merged state (else local refs).
# PATH '-' or empty => operate on the current repo (cwd). Safe as an fzf preview:
# every optional git/gh call is guarded so it never aborts under `set -e`.
cmd_status() {
    local branch_opt="" path="" do_fetch=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --branch) branch_opt="${2:-}"; shift 2 ;;
            --fetch) do_fetch=true; shift ;;
            *)
                if [[ -z "$path" ]] && [[ "$1" != "-" ]]; then
                    path="$1"
                fi
                shift
                ;;
        esac
    done

    # git/gh run against PATH when given, else the current dir.
    local gitc=(git)
    local in_place=true
    if [[ -n "$path" ]]; then
        if [[ ! -d "$path" ]]; then
            echo "Worktree path missing/stale: $path"
            return 0
        fi
        gitc=(git -C "$path")
        in_place=false
    fi

    local cur_branch branch worktree_mode detached_sha=""
    cur_branch=$("${gitc[@]}" branch --show-current 2>/dev/null || true)
    if [[ -n "$branch_opt" ]]; then
        branch="$branch_opt"
    else
        branch="$cur_branch"
    fi
    # Worktree mode = we are describing what is actually checked out here.
    if [[ -z "$branch_opt" ]] || [[ "$branch_opt" == "$cur_branch" ]]; then
        worktree_mode=true
    else
        worktree_mode=false
    fi
    if [[ -z "$branch" ]]; then
        detached_sha=$("${gitc[@]}" rev-parse --short HEAD 2>/dev/null || true)
    fi

    # Repo name: for a linked worktree, --show-toplevel is the worktree dir, so
    # derive from --git-common-dir (which points at <mainrepo>/.git) when it's a
    # linked worktree; else fall back to the toplevel basename.
    local repo_name default_br common toplevel
    common=$("${gitc[@]}" rev-parse --git-common-dir 2>/dev/null || true)
    toplevel=$("${gitc[@]}" rev-parse --show-toplevel 2>/dev/null || true)
    if [[ "$common" == */.git ]]; then
        repo_name=$(basename "$(dirname "$common")")
    elif [[ -n "$toplevel" ]]; then
        repo_name=$(basename "$toplevel")
    else
        repo_name="?"
    fi
    if [[ "$in_place" == true ]]; then
        default_br=$(get_default_branch)
    else
        default_br=$(cd "$path" && get_default_branch)
    fi

    local tmux_state="n/a"
    if [[ -n "${TMUX:-}" ]] && [[ -n "$path" ]]; then
        local cpath ap
        cpath=$(canon_path "$path")
        tmux_state="orphan"
        while IFS= read -r ap; do
            [[ -z "$ap" ]] && continue
            if [[ "$(canon_path "$ap")" == "$cpath" ]]; then tmux_state="attached"; break; fi
        done < <(attached_worktree_paths)
    fi

    echo "Worktree: ${path:-<current repo>}"
    echo "  repo:    $repo_name"
    echo "  tmux:    $tmux_state"
    if [[ -n "$branch" ]]; then
        echo "  branch:  $branch$([[ "$worktree_mode" == false ]] && echo "  (not checked out here)")"
    else
        echo "  branch:  (detached HEAD at ${detached_sha:-?})"
    fi
    echo

    if [[ "$worktree_mode" == true ]]; then
        local st
        st=$("${gitc[@]}" status -s 2>/dev/null || true)
        if [[ -z "$st" ]]; then
            echo "Working tree: clean"
        else
            local nch
            nch=$(printf '%s\n' "$st" | grep -c . || true)
            echo "Working tree: ${nch} change(s)"
            printf '%s\n' "$st" | head -20 | sed 's/^/  /'
        fi
        local ab
        ab=$("${gitc[@]}" rev-list --left-right --count '@{upstream}...HEAD' 2>/dev/null || true)
        if [[ -n "$ab" ]]; then
            local behind ahead
            behind=$(printf '%s' "$ab" | awk '{print $1}')
            ahead=$(printf '%s' "$ab" | awk '{print $2}')
            echo "Upstream: behind ${behind:-0}, ahead ${ahead:-0}"
        else
            echo "Upstream: none"
        fi
    else
        echo "Working tree: n/a (branch not checked out here)"
        echo "Upstream: n/a (branch not checked out here)"
    fi
    echo

    if [[ -n "$branch" ]]; then
        if [[ "$do_fetch" == true ]]; then
            # --fetch: contact origin so existence + merged reflect what is ACTUALLY
            # on the remote right now (not just the last local fetch). Fetch updates
            # the branch + default tips; ls-remote is the definitive existence check.
            "${gitc[@]}" fetch --quiet origin "$branch" "$default_br" 2>/dev/null || true
            local remote_live
            remote_live=$("${gitc[@]}" ls-remote --heads origin "$branch" 2>/dev/null || true)
            if [[ -n "$remote_live" ]]; then
                echo "Remote branch: exists on origin"
            else
                echo "Remote branch: not on origin (deleted/merged or never pushed)"
            fi
        else
            # Default: use the local remote-tracking ref (instant, no network). This
            # reflects the last fetch; pass --fetch (as 'gas pick' does) for live state.
            if "${gitc[@]}" rev-parse --verify --quiet "refs/remotes/origin/$branch" >/dev/null 2>&1; then
                echo "Remote branch: exists on origin (as of last fetch)"
            else
                echo "Remote branch: not on origin (deleted/merged or never pushed; 'git fetch --prune' to refresh)"
            fi
        fi

        # Ref to test for merged-ness: HEAD in worktree mode, else the branch ref.
        local merge_ref="HEAD"
        if [[ "$worktree_mode" == false ]]; then
            if "${gitc[@]}" rev-parse --verify --quiet "refs/heads/$branch" >/dev/null 2>&1; then
                merge_ref="$branch"
            elif "${gitc[@]}" rev-parse --verify --quiet "refs/remotes/origin/$branch" >/dev/null 2>&1; then
                merge_ref="origin/$branch"
            else
                merge_ref="$branch"
            fi
        fi
        local base_ref="origin/$default_br"
        if ! "${gitc[@]}" rev-parse --verify --quiet "$base_ref" >/dev/null 2>&1; then
            base_ref="$default_br"
        fi
        if "${gitc[@]}" merge-base --is-ancestor "$merge_ref" "$base_ref" 2>/dev/null; then
            echo "Merged: yes (into $base_ref)"
        else
            echo "Merged: no (relative to $base_ref)"
        fi
    else
        echo "Remote branch: n/a (detached HEAD)"
        echo "Merged: n/a (detached HEAD)"
    fi
    echo

    if ! command -v gh &>/dev/null; then
        echo "PR: gh not installed — PR status unavailable"
        return 0
    fi
    if [[ -z "$branch" ]]; then
        echo "PR: n/a (detached HEAD)"
        return 0
    fi
    local pr_json
    if [[ -n "$path" ]]; then
        pr_json=$(cd "$path" && gh pr view "$branch" --json state,number,title,url,mergedAt 2>/dev/null || true)
    else
        pr_json=$(gh pr view "$branch" --json state,number,title,url,mergedAt 2>/dev/null || true)
    fi
    if [[ -z "$pr_json" ]]; then
        echo "PR: none found for branch '$branch'"
        return 0
    fi
    if command -v jq &>/dev/null; then
        printf '%s' "$pr_json" | jq -r '"PR: #\(.number) \(.state)" + (if .mergedAt then " (merged \(.mergedAt))" else "" end) + "\n  \(.title)\n  \(.url)"' 2>/dev/null || echo "PR: $pr_json"
    else
        echo "PR: $pr_json"
    fi
}

# Echo the tmux window index whose @agent-worktree equals PATH (canon-compared),
# else empty. Never errors (safe under set -e / outside tmux).
attached_window_index() {
    local path="$1" cpath idx wt
    [[ -z "${TMUX:-}" ]] && return 0
    cpath=$(canon_path "$path")
    while IFS= read -r idx; do
        [[ -z "$idx" ]] && continue
        wt=$(tmux show-window-option -t ":$idx" -v @agent-worktree 2>/dev/null || true)
        [[ -z "$wt" ]] && continue
        if [[ "$(canon_path "$wt")" == "$cpath" ]]; then
            echo "$idx"
            return 0
        fi
    done < <(tmux list-windows -F '#{window_index}' 2>/dev/null || true)
    return 0
}

# Ask a y/N question on the controlling terminal. Returns 0 only on an explicit
# yes; non-zero on no or when there is no terminal to prompt on. Default = No.
confirm() {
    local msg="$1" ans=""
    printf '%s [y/N]: ' "$msg" > /dev/tty 2>/dev/null || return 1
    IFS= read -r ans < /dev/tty 2>/dev/null || true
    case "$ans" in
        y|Y|yes|YES|Yes) return 0 ;;
        *) return 1 ;;
    esac
}

# Wait for a single keypress so action output stays visible before the picker
# redraws over it. No-op when there is no terminal.
pause_for_key() {
    printf '%s' "${1:-  — press any key to return to the picker —}" > /dev/tty 2>/dev/null || return 0
    IFS= read -r -n1 -s _ < /dev/tty 2>/dev/null || true
    printf '\n' > /dev/tty 2>/dev/null || true
}

# Switch to the live tmux window for a worktree path, or open a new one on it.
open_or_switch_worktree() {
    # agent_sel empty => let the opened window resolve the configured default.
    local path="$1" name="${2:-}" agent_sel="${3:-}"
    [[ -z "$name" ]] && name=$(basename "$path")
    local idx
    idx=$(attached_window_index "$path")
    if [[ -n "$idx" ]]; then
        tmux select-window -t ":$idx"
        echo "Switched to window :$idx ($path)"
        return 0
    fi
    if [[ -z "${TMUX:-}" ]]; then
        echo "Error: Not running inside tmux. Start tmux to open a window." >&2
        return 1
    fi
    # No live window: open one on the existing worktree. Only pass --agent when a
    # specific one was requested; otherwise the new window resolves the default.
    local self
    self=$(resolve_self)
    local open_args=(--open-worktree "$path" -n "$name")
    [[ -n "$agent_sel" ]] && open_args+=(--agent "$agent_sel")
    "$self" new "${open_args[@]}"
}

# Remove a worktree and drop it from git metadata, the snapshot, and the registry.
# Best-effort; derives the owning repo from the worktree so it works regardless of
# the current directory (pick lists worktrees across repos).
remove_worktree() {
    local p="$1" common main
    common=$(git -C "$p" rev-parse --git-common-dir 2>/dev/null || true)
    if [[ "$common" == */.git ]]; then
        main=$(dirname "$common")
    else
        main=$(git -C "$p" rev-parse --show-toplevel 2>/dev/null || true)
    fi
    if [[ -n "$main" ]]; then
        git -C "$main" worktree remove "$p" --force 2>/dev/null || true
        git -C "$main" worktree prune 2>/dev/null || true
    fi
    snapshot_remove_by_worktree "$p"
    registry_remove "$p"
}

# Build the worktree picker rows: path<TAB>repo<TAB>status<TAB>branch (field 1 hidden
# but feeds the preview {1} and selection). Grouped by status, then repo, then name.
# Echoes nothing when there are no live worktrees.
pick_build_worktree_rows() {
    local attached path branch repo created status rows=""
    attached=$(attached_worktree_paths)
    while IFS='|' read -r path branch repo created; do
        [[ -z "$path" ]] && continue
        status="orphan"
        if printf '%s\n' "$attached" | grep -Fxq -- "$path"; then
            status="attached"
        fi
        rows+="${path}"$'\t'"$(basename "$repo")"$'\t'"${status}"$'\t'"${branch}"$'\n'
    done < <(registry_list_live)
    [[ -z "$rows" ]] && return 0
    printf '%s' "$rows" | sort -t$'\t' -k3,3 -k2,2 -k4,4
}

# ctrl-a actions menu for a worktree row. Returns 2 for a terminal action
# (open/switch, which leaves the picker); 0 otherwise (caller loops back to the
# refreshed list). All non-terminal actions are guarded and pause so output is seen.
worktree_actions_menu() {
    local path="$1" branch="$2"
    local dev="${AGENT_SESSION_DEV_BRANCH:-develop}"
    local choice
    choice=$(printf '%s\n' \
        "Open / switch to window" \
        "Update from $dev (pull origin $dev)" \
        "Fetch / refresh remote" \
        "Open PR in browser" \
        "Copy path to clipboard" \
        "Remove worktree" \
        | fzf --no-multi --prompt='action> ' \
              --header="Actions: $(basename "$path")  [$branch]" || true)
    [[ -z "$choice" ]] && return 0
    case "$choice" in
        "Open / switch"*)
            open_or_switch_worktree "$path" "$branch"
            return 2
            ;;
        "Update from"*)
            echo "Pulling origin/$dev into '$branch' ..."
            git -C "$path" pull --no-edit origin "$dev" || echo "Pull failed or has conflicts — resolve in $path"
            pause_for_key
            ;;
        "Fetch"*)
            echo "Fetching origin (prune) ..."
            git -C "$path" fetch --prune origin 2>&1 || true
            echo "Done."
            pause_for_key
            ;;
        "Open PR"*)
            if command -v gh &>/dev/null; then
                ( cd "$path" && gh pr view "$branch" --web ) 2>/dev/null \
                    || echo "No PR for '$branch' (create one with: gh pr create)"
            else
                echo "gh not installed."
            fi
            pause_for_key
            ;;
        "Copy path"*)
            if command -v pbcopy &>/dev/null; then
                printf '%s' "$path" | pbcopy && echo "Copied: $path"
            else
                echo "pbcopy unavailable. Path: $path"
            fi
            pause_for_key
            ;;
        "Remove worktree"*)
            local idx
            idx=$(attached_window_index "$path")
            if [[ -n "$idx" ]]; then
                if confirm "Window :$idx is attached. Kill it and remove worktree $path?"; then
                    tmux kill-window -t ":$idx" 2>/dev/null || true
                    remove_worktree "$path"
                    echo "Killed window :$idx and removed: $path"
                else
                    echo "Cancelled (window still attached)."
                fi
            else
                if confirm "Remove worktree $path?"; then
                    remove_worktree "$path"
                    echo "Removed: $path"
                else
                    echo "Cancelled."
                fi
            fi
            pause_for_key
            ;;
    esac
    return 0
}

# --- Subcommand: pick (fzf worktree picker with rich preview + actions menu) ---
cmd_pick() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required for 'agent-session pick'. Install fzf first." >&2
        exit 1
    fi
    local self
    self=$(resolve_self)
    while true; do
        local rows
        rows=$(pick_build_worktree_rows)
        if [[ -z "$rows" ]]; then
            echo "No agent-session worktrees (registry empty or all stale)."
            exit 0
        fi
        local out key sel
        out=$(printf '%s\n' "$rows" | fzf --no-multi --ansi \
            --delimiter=$'\t' --with-nth=2,3,4 --expect=ctrl-a \
            --header='enter: open/switch   ctrl-a: actions…    (repo | status | branch)' \
            --preview="$self status --fetch {1}" \
            --preview-window='right,60%,wrap' || true)
        [[ -z "$out" ]] && exit 0
        key=$(printf '%s\n' "$out" | sed -n '1p')
        sel=$(printf '%s\n' "$out" | sed -n '2p')
        [[ -z "$sel" ]] && exit 0
        local sel_path sel_branch
        sel_path=$(printf '%s' "$sel" | cut -f1)
        sel_branch=$(printf '%s' "$sel" | cut -f4)
        if [[ "$key" == "ctrl-a" ]]; then
            # Return 0 => loop (refresh list); return 2 => terminal action, done.
            if worktree_actions_menu "$sel_path" "$sel_branch"; then
                continue
            else
                exit 0
            fi
        else
            open_or_switch_worktree "$sel_path" "$sel_branch"
            exit 0
        fi
    done
}

# Create a worktree that checks out an EXISTING branch (local or remote-only).
# Echoes the created path on success; empty on failure.
create_worktree_for_branch() {
    local branch="$1"
    local main_repo
    main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
    [[ -z "$main_repo" ]] && { echo ""; return 1; }
    local repo_name base_dir
    repo_name=$(basename "$main_repo")
    base_dir=$(get_worktree_base "$worktree_base")/"$repo_name"
    mkdir -p "$base_dir"
    git -C "$main_repo" worktree prune 2>/dev/null || true

    local slug
    slug=$(printf '%s' "$branch" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
    local wt_path="${base_dir}/branch-${slug}"
    local n=0
    while [[ -e "$wt_path" ]]; do
        n=$((n + 1)); wt_path="${base_dir}/branch-${slug}-$n"
    done

    local add_err=""
    if git -C "$main_repo" show-ref --verify --quiet "refs/heads/$branch"; then
        if ! add_err=$(git -C "$main_repo" worktree add "$wt_path" "$branch" 2>&1); then
            echo "Error: git worktree add failed for '$branch': $add_err" >&2
            echo ""; return 1
        fi
    else
        if ! add_err=$(git -C "$main_repo" worktree add -b "$branch" "$wt_path" "origin/$branch" 2>&1); then
            echo "Error: git worktree add failed for 'origin/$branch': $add_err" >&2
            echo ""; return 1
        fi
    fi
    registry_add "$wt_path" "$branch" "$main_repo" "$branch" "$main_repo"
    echo "$wt_path"
}

open_or_switch_branch() {
    local branch="$1" existing_path="${2:-}"
    if [[ -n "$existing_path" ]] && [[ "$existing_path" != "-" ]] && [[ -d "$existing_path" ]]; then
        open_or_switch_worktree "$existing_path" "$branch"
        return $?
    fi
    # A branch checked out in the MAIN repo working copy can't also be added as a
    # worktree; open a window rooted there instead of creating a divergent branch.
    local main_repo main_current
    main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
    if [[ -n "$main_repo" ]]; then
        main_current=$(git -C "$main_repo" branch --show-current 2>/dev/null || true)
        if [[ -n "$main_current" ]] && [[ "$main_current" == "$branch" ]]; then
            echo "Branch '$branch' is checked out in the main repo ($main_repo)." >&2
            echo "Opening a window rooted there instead of creating a worktree." >&2
            local self
            self=$(resolve_self)
            "$self" new --dir "$main_repo" -n "$branch"
            return $?
        fi
    fi
    local new_path
    new_path=$(create_worktree_for_branch "$branch")
    if [[ -z "$new_path" ]]; then
        echo "Failed to create worktree for branch '$branch'." >&2
        return 1
    fi
    open_or_switch_worktree "$new_path" "$branch"
}

# Build the branch picker rows: branch<TAB>path-or-'-'<TAB>state (local + remote-only).
# Fast, local-only (no per-row network). Echoes nothing when there are no branches.
pick_build_branch_rows() {
    local main_repo="$1"
    # Map each checked-out branch to its worktree path (parse porcelain output).
    local wt_map="" line cur_path=""
    while IFS= read -r line; do
        if [[ "$line" == worktree\ * ]]; then
            cur_path="${line#worktree }"
        elif [[ "$line" == branch\ * ]]; then
            local ref="${line#branch }"
            wt_map+="${ref#refs/heads/}"$'\t'"${cur_path}"$'\n'
        fi
    done < <(git -C "$main_repo" worktree list --porcelain 2>/dev/null || true)

    # Snapshot local branches once (also used to subtract from the remote set).
    local local_branches
    local_branches=$(git -C "$main_repo" for-each-ref --format='%(refname:short)' refs/heads 2>/dev/null || true)

    local rows="" b wp hw bn wpath
    while IFS= read -r b; do
        [[ -z "$b" ]] && continue
        wp=""
        while IFS=$'\t' read -r bn wpath; do
            [[ "$bn" == "$b" ]] && { wp="$wpath"; break; }
        done < <(printf '%s' "$wt_map")
        hw="-"
        [[ -n "$wp" ]] && hw="worktree"
        rows+="${b}"$'\t'"${wp:--}"$'\t'"${hw}"$'\n'
    done <<< "$local_branches"

    # Remote-only branches = origin/* minus HEAD minus any local branch of the same
    # name. Single awk pass (no per-branch subprocess).
    local remote_only
    remote_only=$(awk '
        NR==FNR { loc[$0]=1; next }
        /^origin\// {
            b=$0; sub(/^origin\//, "", b)
            if (b == "HEAD") next
            if (!(b in loc)) print b
        }
    ' <(printf '%s\n' "$local_branches") \
      <(git -C "$main_repo" for-each-ref --format='%(refname:short)' refs/remotes/origin 2>/dev/null || true) 2>/dev/null || true)
    while IFS= read -r b; do
        [[ -z "$b" ]] && continue
        rows+="${b}"$'\t'"-"$'\t'"remote-only"$'\n'
    done <<< "$remote_only"

    printf '%s' "$rows"
}

# ctrl-a actions menu for a branch row. Returns 2 for a terminal action
# (open/switch), 0 otherwise. Worktree-only actions (remove, update-from-develop)
# appear only when the branch already has a worktree.
branch_actions_menu() {
    local branch="$1" path="$2"
    local dev="${AGENT_SESSION_DEV_BRANCH:-develop}"
    local has_wt=false
    [[ -n "$path" ]] && [[ "$path" != "-" ]] && [[ -d "$path" ]] && has_wt=true
    local menu
    if [[ "$has_wt" == true ]]; then
        menu=$(printf '%s\n' \
            "Open / switch to worktree" \
            "Update from $dev (pull origin $dev)" \
            "Fetch / refresh remote" \
            "Open PR in browser" \
            "Copy path to clipboard" \
            "Remove worktree")
    else
        menu=$(printf '%s\n' \
            "Open / switch to worktree" \
            "Fetch / refresh remote" \
            "Open PR in browser" \
            "Copy branch name")
    fi
    local choice
    choice=$(printf '%s\n' "$menu" | fzf --no-multi --prompt='action> ' \
        --header="Actions: $branch" || true)
    [[ -z "$choice" ]] && return 0
    case "$choice" in
        "Open / switch"*)
            open_or_switch_branch "$branch" "$path"
            return 2
            ;;
        "Update from"*)
            echo "Pulling origin/$dev into '$branch' ..."
            git -C "$path" pull --no-edit origin "$dev" || echo "Pull failed or has conflicts — resolve in $path"
            pause_for_key
            ;;
        "Fetch"*)
            echo "Fetching origin (prune) ..."
            if [[ "$has_wt" == true ]]; then
                git -C "$path" fetch --prune origin 2>&1 || true
            else
                git fetch --prune origin 2>&1 || true
            fi
            echo "Done."
            pause_for_key
            ;;
        "Open PR"*)
            if command -v gh &>/dev/null; then
                gh pr view "$branch" --web 2>/dev/null \
                    || echo "No PR for '$branch' (create one with: gh pr create)"
            else
                echo "gh not installed."
            fi
            pause_for_key
            ;;
        "Copy path"*)
            if command -v pbcopy &>/dev/null; then
                printf '%s' "$path" | pbcopy && echo "Copied: $path"
            else
                echo "pbcopy unavailable. Path: $path"
            fi
            pause_for_key
            ;;
        "Copy branch name"*)
            if command -v pbcopy &>/dev/null; then
                printf '%s' "$branch" | pbcopy && echo "Copied: $branch"
            else
                echo "pbcopy unavailable. Branch: $branch"
            fi
            pause_for_key
            ;;
        "Remove worktree"*)
            local idx
            idx=$(attached_window_index "$path")
            if [[ -n "$idx" ]]; then
                if confirm "Window :$idx is attached. Kill it and remove worktree $path?"; then
                    tmux kill-window -t ":$idx" 2>/dev/null || true
                    remove_worktree "$path"
                    echo "Killed window :$idx and removed: $path"
                else
                    echo "Cancelled (window still attached)."
                fi
            else
                if confirm "Remove worktree $path?"; then
                    remove_worktree "$path"
                    echo "Removed: $path"
                else
                    echo "Cancelled."
                fi
            fi
            pause_for_key
            ;;
    esac
    return 0
}

# --- Subcommand: branches (fzf branch picker with rich preview + actions menu) ---
cmd_pick_branch() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required for 'agent-session branches'. Install fzf first." >&2
        exit 1
    fi
    local main_repo
    main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
    if [[ -z "$main_repo" ]]; then
        echo "Error: Not in a git repository." >&2
        exit 1
    fi
    local self
    self=$(resolve_self)
    while true; do
        local rows
        rows=$(pick_build_branch_rows "$main_repo")
        if [[ -z "$rows" ]]; then
            echo "No branches found."
            exit 0
        fi
        local out key sel
        out=$(printf '%s' "$rows" | fzf --no-multi \
            --delimiter=$'\t' --with-nth=1,3 --expect=ctrl-a \
            --header='enter: open/switch   ctrl-a: actions…    (branch | state)' \
            --preview="$self status --branch {1} {2}" \
            --preview-window='right,60%,wrap' || true)
        [[ -z "$out" ]] && exit 0
        key=$(printf '%s\n' "$out" | sed -n '1p')
        sel=$(printf '%s\n' "$out" | sed -n '2p')
        [[ -z "$sel" ]] && exit 0
        local sel_branch sel_path
        sel_branch=$(printf '%s' "$sel" | cut -f1)
        sel_path=$(printf '%s' "$sel" | cut -f2)
        if [[ "$key" == "ctrl-a" ]]; then
            if branch_actions_menu "$sel_branch" "$sel_path"; then
                continue
            else
                exit 0
            fi
        else
            open_or_switch_branch "$sel_branch" "$sel_path"
            exit 0
        fi
    done
}

# --- Subcommand: dev (shortcut for the most common worktree case) ---
# `gas dev NAME [PROMPT/flags...]` == `gas --worktree --branch develop -n NAME ...`
# Base branch defaults to 'develop'; override with $AGENT_SESSION_DEV_BRANCH.
cmd_dev() {
    if [[ $# -lt 1 ]] || [[ -z "${1:-}" ]]; then
        echo "Usage: ${prog} dev NAME [PROMPT...]  (worktree off '${AGENT_SESSION_DEV_BRANCH:-develop}' named NAME)" >&2
        exit 1
    fi
    local name="$1"; shift
    local dev_branch="${AGENT_SESSION_DEV_BRANCH:-develop}"
    local self
    self=$(resolve_self)
    exec "$self" new --worktree --branch "$dev_branch" -n "$name" "$@"
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
    # Best-effort listing: never let a non-zero pipeline status (e.g. the final
    # window lacking @agent-worktree, or pipefail on a tmux hiccup) abort callers
    # running under `set -e` when this is used in `$(...)` command substitution.
    return 0
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
        local restore_cmd
        restore_cmd=$(resolve_agent_command "$agent")
        tmux send-keys -t ":$new_window" "$restore_cmd" Enter
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

# --- Subcommand: list ---
# Output: window name, worktree or dir, agent, ticket, attached|orphan
cmd_list() {
    local snap
    snap=$(get_snapshot_file)
    if [[ ! -f "$snap" ]] || ! [[ -s "$snap" ]]; then
        echo "No snapshot. File: $snap"
        return 0
    fi
    # Build sets of current window names and worktree paths from tmux as
    # newline-delimited strings (portable to bash 3.2, which lacks associative
    # arrays).
    local window_names=""
    local window_worktrees=""
    if [[ -n "${TMUX:-}" ]]; then
        local idx name wt
        while IFS='|' read -r idx name; do
            [[ -z "$idx" ]] && continue
            window_names+="$name"$'\n'
            wt=$(tmux show-window-option -t ":$idx" -v @agent-worktree 2>/dev/null || true)
            if [[ -n "$wt" ]]; then
                window_worktrees+="$wt"$'\n'
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
            if printf '%s' "$window_names" | grep -Fxq -- "$window_name"; then
                status="attached"
            elif [[ -n "$worktree_path" ]] && printf '%s' "$window_worktrees" | grep -Fxq -- "$worktree_path"; then
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
    local agent_script
    agent_script=$(resolve_self)
    # Resolve (and, if needed, prompt for + persist) the harness command once up
    # front so the per-line child invocations don't each try to prompt — important
    # since batch windows may be created detached.
    if [[ -z "$batch_agent_val" ]]; then
        batch_agent_val=$(get_or_prompt_harness_command) || exit 1
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
        "$agent_script" new "${opts[@]}"
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

    # Collect attached worktree paths into a newline-delimited string (portable
    # to bash 3.2, which lacks associative arrays).
    local attached_paths
    attached_paths=$(attached_worktree_paths)

    # Emit one row per worktree (resolving current branch and attached/orphan/
    # stale status), then render as JSON via jq. Falls back to a plain table when
    # jq isn't installed. Fields are joined with the unit-separator (0x1f) rather
    # than a tab: tab is a whitespace IFS char, so `read` would collapse the
    # empty branch/base fields of stale rows and shift every column.
    local SEP=$'\037'
    system_emit_rows() {
        local path branch repo created base_branch source_dir
        while IFS='|' read -r path branch repo created base_branch source_dir; do
            [[ -z "$path" ]] && continue
            local current_br repo_name status stale
            repo_name=$(basename "$repo" 2>/dev/null) || repo_name="$repo"
            if [[ ! -d "$path" ]]; then
                current_br=""; status="stale"; stale="true"
            else
                current_br=$(git -C "$path" branch --show-current 2>/dev/null) || current_br=""
                stale="false"; status="orphan"
                if printf '%s\n' "$attached_paths" | grep -Fxq -- "$path"; then
                    status="attached"
                fi
            fi
            printf '%s\n' "${path}${SEP}${current_br}${SEP}${base_branch:-}${SEP}${repo_name}${SEP}${created:-}${SEP}${status}${SEP}${stale}"
        done < "$reg"
    }

    if command -v jq &>/dev/null; then
        system_emit_rows | jq -R -s '
            split("\n") | map(select(length > 0)) | map(split("\u001f")) | map({
                path:     .[0],
                branch:  (if .[1] == "" then null else .[1] end),
                base:    (if .[2] == "" then null else .[2] end),
                repo:     .[3],
                created: (if .[4] == "" then null else .[4] end),
                status:   .[5],
                stale:   (.[6] == "true")
            })'
    else
        printf "%-50s %-30s %-12s %-10s %-8s\n" "PATH" "BRANCH" "BASE" "REPO" "STATUS"
        printf "%-50s %-30s %-12s %-10s %-8s\n" "----" "-----" "----" "----" "------"
        system_emit_rows | while IFS="$SEP" read -r path branch base repo created status stale; do
            if [[ "$stale" == "true" ]]; then
                printf "%-50s (stale - missing)\n" "$path"
            else
                printf "%-50s %-30s %-12s %-10s %-8s\n" "$path" "${branch:-?}" "${base:-?}" "$repo" "$status"
            fi
        done
    fi
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

    # Newline-delimited set of attached worktree paths (portable to bash 3.2,
    # which lacks associative arrays).
    local prune_attached_paths
    prune_attached_paths=$(attached_worktree_paths)

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
        if printf '%s\n' "$prune_attached_paths" | grep -Fxq -- "$wt"; then
            wt_status="attached"
        fi
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
        new|create)
            subcommand=new
            shift
            break
            ;;
        switch)
            subcommand=switch
            shift
            break
            ;;
        config)
            subcommand=config
            shift
            break
            ;;
        dev)
            subcommand=dev
            shift
            break
            ;;
        status)
            subcommand=status
            shift
            break
            ;;
        pick|worktrees)
            subcommand=pick
            shift
            break
            ;;
        pick-branch|branches)
            subcommand=pick_branch
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
        list)
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
if [[ "$subcommand" == config ]]; then
    cmd_config "$@"
    exit 0
fi
if [[ "$subcommand" == dev ]]; then
    cmd_dev "$@"
    exit 0
fi
if [[ "$subcommand" == status ]]; then
    cmd_status "$@"
    exit 0
fi
if [[ "$subcommand" == pick ]]; then
    cmd_pick "$@"
    exit 0
fi
if [[ "$subcommand" == pick_branch ]]; then
    cmd_pick_branch "$@"
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

# No recognized subcommand. The create-a-window behavior now lives behind the
# 'new' (alias 'create') subcommand; a bare invocation or unrecognized input no
# longer silently creates a window.
if [[ "$subcommand" == new ]]; then
    # Args after the 'new' token become the create-session parser's input.
    remaining=("$@")
else
    # Bare `gas` with no args: show help and exit cleanly.
    if [[ ${#remaining[@]} -eq 0 ]]; then
        usage
        exit 0
    fi
    # -h/--help among the leftover args shows help and exits cleanly.
    for a in "${remaining[@]}"; do
        case "$a" in
            -h|--help) usage; exit 0 ;;
        esac
    done
    # Anything else is unrecognized: warn, show help, exit non-zero.
    echo "Error: unrecognized command or parameters: ${remaining[*]}" >&2
    echo "Did you mean '${prog} new ${remaining[*]}'? Run '${prog} --help' for usage." >&2
    echo >&2
    usage >&2
    exit 1
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
            agent="${remaining[$i]:-}"
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
        --open-worktree)
            ((i++)) || true
            open_worktree="${remaining[$i]:-}"
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

if [[ -z "${TMUX:-}" ]]; then
    echo "Error: Not running inside tmux. Run this script from within a tmux session." >&2
    exit 1
fi

# Resolve the harness command to launch (cursor/claude aliases, a literal command,
# or the per-machine configured default — prompting once if it isn't set yet).
# After the tmux check so a not-in-tmux invocation fails fast without prompting.
agent_cmd=$(resolve_agent_command "$agent") || exit 1
# Record the resolved command so the snapshot/list/restore reflect exactly what ran.
agent="$agent_cmd"

# --- Worktree creation ---
session_cwd=""
worktree_path=""
if [[ -n "$open_worktree" ]] && [[ "$worktree" == true ]]; then
    echo "Error: --open-worktree and --worktree are mutually exclusive." >&2
    exit 1
fi
# Open a window on an EXISTING worktree (does not create a new one). Reuses the
# window-creation tail below by pre-seeding worktree_path/session_cwd.
if [[ -n "$open_worktree" ]]; then
    if [[ ! -d "$open_worktree" ]]; then
        echo "Error: --open-worktree: path does not exist: $open_worktree" >&2
        exit 1
    fi
    worktree_path="$open_worktree"
    session_cwd="$open_worktree"
    [[ -z "$window_name" ]] && [[ -z "$window_path" ]] && window_name=$(basename "$open_worktree")
fi
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
    # Slug the window name/path into the branch so it's recognizable at a glance
    # (git-safe: lowercased, runs of non-alphanumerics collapsed to a single '-').
    window_label="$window_name"
    [[ -z "$window_label" && -n "$window_path" ]] && window_label=$(basename "$window_path")
    window_slug=$(printf '%s' "$window_label" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')

    # Guaranteed-unique branch name ($$ avoids same-second collisions in create-batch).
    branch_prefix="agent-${repo_name}${window_slug:+-${window_slug}}"
    unique_branch="${branch_prefix}-$(date +%Y%m%d-%H%M%S)-$$"
    n=0
    while git -C "$source_repo" show-ref --verify --quiet "refs/heads/${unique_branch}"; do
        n=$((n + 1))
        unique_branch="${branch_prefix}-$(date +%Y%m%d-%H%M%S)-$$-$n"
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
tmux send-keys -t ":$new_window" "$agent_cmd" Enter

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
