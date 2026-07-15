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
# Explicit new-branch name for --worktree (else an auto agent-<repo>-<slug> name).
branch_name=""
# Force Claude's interactive `--resume` picker instead of the default continue/new.
claude_resume=false

usage() {
    cat << EOF
Usage: ${prog} new [OPTIONS] [NAME] [PROMPT]   (create a window; alias: create)
       ${prog} dev NAME [PROMPT]        # shortcut: new --worktree --branch develop -n NAME
       ${prog} fork [--deep] [--branch BR] REPO [NAME] [PROMPT]   # clone a repo + open a window
       ${prog} jira [KEY]               # pick a Jira ticket -> worktree window
       ${prog} jira list                # list your open-sprint issues
       ${prog} jira create              # create a ticket interactively (via acli)
       ${prog} create-batch FILE [OPTIONS]
       ${prog} switch
       ${prog} pick
       ${prog} branches
       ${prog} status [--branch BRANCH] [--fetch] [PATH]
       ${prog} sessions [PATH]          # list Claude sessions for a worktree
       ${prog} edit                     # fzf-edit this project's skills/rules/subagents
       ${prog} config [harness-command|jira-subdomain|jira-branch-prefix|jira-project [VALUE]]
       ${prog} install PKG [--brew|--cargo|--pip|--apt]   # install+track a tool (no flag = auto)
       ${prog} install --curl URL NAME [--bin P] [--uninstall CMD]  # install via curl|bash
       ${prog} install --discover [--MGR] [-n]   # import already-installed tools into tracking
       ${prog} install [--list|--outdated]   # list tracked tools / check updates (bare = fzf menu)
       ${prog} note --new TITLE [--body -|TEXT]   # create a note (stdin/--body = non-interactive)
       ${prog} note --append NAME [--body -|TEXT]  # append to a note (auto-creates)
       ${prog} note [--edit|--cat|--path|--delete] [NAME] | --search TERM | --list [--json]
       ${prog} list
       ${prog} system [--purge] [--worktree-base DIR]
       ${prog} system remove PATH
       ${prog} prune [OPTIONS] [PATH]
       ${prog} doctor [--fix | -i]
       ${prog} cleanup

Creates a new tmux window with 2 vertical panes (agent in top pane) and switches
to it. Worktrees created with --worktree are recorded in a registry that is the
source of truth; use 'pick'/'branches' to reopen windows and 'doctor' to reconcile.

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
  --branch-name NAME  With --worktree: use NAME as the new branch (may contain '/')
                   instead of the auto agent-<repo>-<slug> name (used by 'jira')
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
  --claude-resume  With a claude harness: open Claude's interactive --resume picker
                   instead of continuing/starting a session (used by the actions menu)
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
  fork REPO [NAME] [PROMPT]  Like 'dev', but clones a DIFFERENT repo (REPO: URL or path)
                   into the clone base and opens a window on it instead of a worktree.
                   Shallow clone by default; --deep for full history. --branch BR clones
                   that branch. NAME defaults to the repo name. Clone base:
                   \$AGENT_SESSION_CLONE_BASE (else beside the worktree base).
  jira [KEY]       fzf-pick a Jira ticket (or pass KEY) from your open sprints and open a
                   worktree window on a fresh branch <prefix>/<KEY>/<slug> (unique; a repeat
                   ticket gets a -part-N suffix), off \$AGENT_SESSION_DEV_BRANCH (develop),
                   tagged --ticket and seeded with the ticket. 'jira list' prints the issues.
                   'jira create' creates a ticket interactively (project, type, summary,
                   component [chosen from the project's existing ones], description,
                   assignee, labels) then forwards to acli and offers a worktree. Config:
                   'config jira-subdomain|jira-branch-prefix|jira-project'.
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
                   Also shows the worktree's Claude session count + last-active.
  sessions [PATH]  List the Claude sessions recorded for a worktree (default: cwd):
                   session ids + last-active, and how to resume. Claude-specific.
  edit             fzf-pick one of this project's skills / rules / subagents and open it in
                   \$EDITOR (else nvim/vim/vi). Ecosystem follows the harness: claude =>
                   .claude/skills/*/SKILL.md, .claude/agents/*.md, CLAUDE.md (project +
                   global); cursor => .cursor/rules/*.mdc, .cursorrules (Cursor has no
                   file-based skills/subagents); other => both.
  install          Install + track a global CLI tool and manage it later. The only
                   positional is the package name; everything else is a flag.
                   'install PKG' tries brew->cargo->pip->apt (first that works);
                   add --brew/--cargo/--pip/--apt to force one. 'install --curl URL
                   NAME [--bin PATH] [--uninstall CMD]' runs curl|bash. '--discover'
                   imports tools you already installed via each manager (add -n to
                   preview). '--list' lists tracked tools; '--outdated' checks latest
                   versions; bare 'install' opens an fzf menu to update/remove/check
                   each. Registry: \$AGENT_SESSION_INSTALLS.
  note             Manage plain-text note files (interactively or non-interactively, for
                   agents). 'note --new TITLE' opens \$EDITOR, or writes directly when a
                   body is given via '--body TEXT' / '--body -' / piped stdin (add
                   --no-edit). 'note --append NAME' appends stdin/--body (auto-creating the
                   note) — the agent scratchpad. '--edit/--cat/--path/--delete [NAME]' act on
                   a note (fzf-pick when NAME omitted and a terminal is present; --delete
                   --yes skips the prompt). '--search TERM' greps all notes (name:line:match);
                   '--list [--json]' lists them (JSON includes bytes/lines). '--project|-p'
                   scopes to the current repo (shared across its worktrees); bare 'note'
                   opens an fzf menu. Notes live in \$AGENT_SESSION_NOTES
                   (default ~/.config/agent-session/notes).
  config           Show or set persistent per-machine config. 'config' lists it; keys:
                   harness-command (cursor-agent/claude), jira-subdomain, jira-branch-prefix.
                   'config KEY' shows a value; 'config KEY VALUE' sets it.
  system           List worktrees created by ${prog} (location and branch).
                   --purge: remove stale registry entries.
                   remove PATH: force-remove worktree and unregister.
  prune            List worktrees and PR status (merged/closed = safe to remove).
                   --registered-only: only worktrees in the registry.
                   --force-remove: remove safe worktrees and unregister.
                   PATH: force-remove that worktree and unregister.
                   --find-by-title TITLE: find commit on develop by message.
  doctor           Reconcile on-disk state with git (tmux-independent). Prunes stale git
                   worktree metadata, removes registry entries whose dirs are gone,
                   and re-adds agent-* worktrees git knows about but the registry doesn't.
                   Read-only by default; --fix applies all removals/re-tracks;
                   -i/--interactive prompts y/N for each item.
  cleanup          Remove the worktree for the current window and close the window
                   (only if window was created with --worktree).
  list             Alias for 'system' (registry worktree listing + attached/orphan/stale).

Examples:
  ${prog} dev my-feature "Implement login"
  ${prog} fork https://github.com/org/repo.git experiment
  ${prog} fork --deep git@github.com:org/repo.git
  ${prog} jira            # pick a sprint ticket -> worktree window
  ${prog} jira list       # list your open-sprint issues
  ${prog} jira create     # create a ticket interactively (via acli)
  ${prog} new my-feature "Implement login"
  ${prog} new --worktree --branch develop
  ${prog} pick
  ${prog} branches
  ${prog} status ~/.local/state/agent-session/worktrees/repo/agent-repo-...
  ${prog} sessions        # Claude sessions for the current worktree
  ${prog} edit            # edit this project's skills/rules/subagents
  ${prog} install ripgrep            # auto: brew->cargo->pip->apt
  ${prog} install cargo bat          # force a specific manager
  ${prog} install curl https://sh.rustup.rs rustup --bin ~/.cargo/bin/rustup
  ${prog} install                    # fzf menu to update/remove tracked tools
  ${prog} install outdated           # check which tracked tools are outdated
  ${prog} system
  ${prog} prune --registered-only
  ${prog} prune --force-remove
  ${prog} doctor --fix
  ${prog} list
  ${prog} cleanup

EOF
}

# --- Persistent config (key=value lines) ---
# Stores per-machine settings such as the harness command to launch (cursor-agent
# on some machines, claude on others). Lives beside the registry under
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

# --- Claude Code session integration (only when the harness is `claude`) ---
# Claude persists each conversation per project directory under
# ${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/<slug>, where <slug> is the cwd's
# canonical path with every non-alphanumeric char replaced by '-'. We only ever
# read the transcript *files* (count + mtime, stable); never their contents (the
# JSONL format is internal to Claude Code and may change between releases).

# Echo the Claude project dir for a worktree/dir path (may not exist).
claude_project_dir() {
    local p slug
    p=$(canon_path "$1")
    slug=$(printf '%s' "$p" | sed 's/[^a-zA-Z0-9]/-/g')
    echo "${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/${slug}"
}

# Echo the worktree's session transcript files, newest first; empty if none.
claude_session_files() {
    local d
    d=$(claude_project_dir "$1")
    [[ -d "$d" ]] || return 0
    ls -t "$d"/*.jsonl 2>/dev/null || true
}

# Human "3m ago" style age from an epoch-seconds delta.
rel_age() {
    local s="$1"
    if [[ "$s" -lt 60 ]]; then echo "${s}s ago"
    elif [[ "$s" -lt 3600 ]]; then echo "$((s / 60))m ago"
    elif [[ "$s" -lt 86400 ]]; then echo "$((s / 3600))h ago"
    else echo "$((s / 86400))d ago"; fi
}

# Echo "N (last active <rel>)" for a worktree's Claude sessions, or empty if none.
claude_sessions_summary() {
    local files n newest now mt
    files=$(claude_session_files "$1")
    [[ -z "$files" ]] && return 0
    n=$(printf '%s\n' "$files" | grep -c . || echo 0)
    newest=$(printf '%s\n' "$files" | head -1)
    mt=$(stat -f %m "$newest" 2>/dev/null || echo "")
    now=$(date +%s)
    if [[ -n "$mt" ]]; then
        echo "${n} (last active $(rel_age $((now - mt))))"
    else
        echo "${n}"
    fi
}

# True when the harness command's first word is `claude`.
is_claude_harness() {
    [[ "${1%% *}" == claude ]]
}

# True when the configured default harness is claude (env/config only; no prompt).
default_harness_is_claude() {
    local h="${AGENT_SESSION_HARNESS_COMMAND:-}"
    [[ -z "$h" ]] && h=$(config_get "$HARNESS_KEY")
    is_claude_harness "$h"
}

# Build the command to type in the pane. For claude, tie into session persistence:
# force the resume picker when requested, else continue the worktree's most recent
# session, else start a fresh named one. Non-claude harnesses pass through unchanged.
claude_launch_command() {
    local cmd="$1" cwd="$2" name="$3"
    if ! is_claude_harness "$cmd"; then
        printf '%s' "$cmd"
        return 0
    fi
    if [[ "${claude_resume:-false}" == true ]]; then
        printf '%s --resume' "$cmd"
    elif [[ -n "$cwd" ]] && [[ -n "$(claude_session_files "$cwd")" ]]; then
        printf '%s --continue' "$cmd"
    elif [[ -n "$name" ]]; then
        printf '%s -n %q' "$cmd" "$name"
    else
        printf '%s' "$cmd"
    fi
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
        jira-subdomain|jira_subdomain)
            if [[ -n "$value" ]]; then
                config_set "$JIRA_SUBDOMAIN_KEY" "$value"
                echo "Set ${JIRA_SUBDOMAIN_KEY} = $value"
            else
                local cur
                cur=$(config_get "$JIRA_SUBDOMAIN_KEY")
                echo "${JIRA_SUBDOMAIN_KEY} = ${cur:-<unset>}"
            fi
            ;;
        jira-branch-prefix|jira_branch_prefix)
            if [[ -n "$value" ]]; then
                config_set "$JIRA_PREFIX_KEY" "$value"
                echo "Set ${JIRA_PREFIX_KEY} = $value"
            else
                local cur
                cur=$(config_get "$JIRA_PREFIX_KEY")
                echo "${JIRA_PREFIX_KEY} = ${cur:-<unset>}"
            fi
            ;;
        jira-project|jira_project)
            if [[ -n "$value" ]]; then
                config_set "$JIRA_PROJECT_KEY" "$value"
                echo "Set ${JIRA_PROJECT_KEY} = $value"
            else
                local cur
                cur=$(config_get "$JIRA_PROJECT_KEY")
                echo "${JIRA_PROJECT_KEY} = ${cur:-<unset>}"
            fi
            ;;
        *)
            echo "Usage: ${prog} config [harness-command|jira-subdomain|jira-branch-prefix|jira-project [VALUE]]" >&2
            exit 1
            ;;
    esac
}

# --- Jira integration (acli-backed; absorbs jirasprintmine/jirabranch) ---
JIRA_SUBDOMAIN_KEY="jira_subdomain"
JIRA_PREFIX_KEY="jira_branch_prefix"
JIRA_PROJECT_KEY="jira_project"
# The JQL both the listing and the picker use: my not-done issues in open sprints.
JIRA_JQL='assignee = currentUser() AND sprint in openSprints() AND statusCategory != Done ORDER BY priority DESC, updated DESC'

jira_require_acli() {
    if ! command -v acli &>/dev/null; then
        echo "Error: 'acli' (Atlassian CLI) is required for '${prog} jira'. Install it (e.g. brew install acli) and run 'acli auth'." >&2
        return 1
    fi
}

# Resolve the Jira subdomain: env > gas config > legacy ~/.jira_instance_subdomain >
# prompt (persisted to gas config). Echoes the subdomain; non-zero if unresolved.
get_jira_subdomain() {
    local sd="${AGENT_SESSION_JIRA_SUBDOMAIN:-}"
    [[ -z "$sd" ]] && sd=$(config_get "$JIRA_SUBDOMAIN_KEY")
    [[ -z "$sd" ]] && [[ -f "$HOME/.jira_instance_subdomain" ]] && sd=$(cat "$HOME/.jira_instance_subdomain" 2>/dev/null || true)
    if [[ -z "$sd" ]]; then
        if ! printf 'Jira instance subdomain (the part before .atlassian.net): ' > /dev/tty 2>/dev/null; then
            echo "Error: jira_subdomain is not set and there is no terminal to prompt on." >&2
            echo "Set it once with: ${prog} config jira-subdomain <name>" >&2
            return 1
        fi
        IFS= read -r sd < /dev/tty || true
        [[ -z "$sd" ]] && { echo "Jira subdomain is required." >&2; return 1; }
    fi
    [[ "$(config_get "$JIRA_SUBDOMAIN_KEY")" != "$sd" ]] && config_set "$JIRA_SUBDOMAIN_KEY" "$sd"
    printf '%s' "$sd"
}

# Branch prefix for Jira worktrees: env > config > prompt (default from gh username).
get_jira_branch_prefix() {
    local p="${AGENT_SESSION_JIRA_BRANCH_PREFIX:-}"
    [[ -z "$p" ]] && p=$(config_get "$JIRA_PREFIX_KEY")
    if [[ -z "$p" ]]; then
        local default=""
        [[ -f "$HOME/.gh_prs_author" ]] && default=$(cat "$HOME/.gh_prs_author" 2>/dev/null || true)
        if ! printf 'Branch prefix for Jira worktrees [%s]: ' "${default:-yourname}" > /dev/tty 2>/dev/null; then
            echo "Error: jira_branch_prefix is not set and there is no terminal to prompt on." >&2
            echo "Set it once with: ${prog} config jira-branch-prefix <name>" >&2
            return 1
        fi
        IFS= read -r p < /dev/tty || true
        [[ -z "$p" ]] && p="$default"
        [[ -z "$p" ]] && { echo "Branch prefix is required." >&2; return 1; }
        config_set "$JIRA_PREFIX_KEY" "$p"
    fi
    printf '%s' "$p"
}

# Fetch my open-sprint issues as JSON (empty/[] handled by callers).
jira_fetch_sprint_json() {
    acli jira workitem search --jql="$JIRA_JQL" --json 2>/dev/null || true
}

# Prompt on the controlling terminal with an optional default; echo the reply (or
# the default on empty). Returns non-zero when there is no terminal.
jira_prompt() {
    local msg="$1" def="${2:-}" reply="" shown="$1"
    [[ -n "$def" ]] && shown="$msg [$def]"
    printf '%s: ' "$shown" > /dev/tty 2>/dev/null || return 1
    IFS= read -r reply < /dev/tty || true
    [[ -z "$reply" ]] && reply="$def"
    printf '%s' "$reply"
}

# Default project key for new tickets: env > config > prompt (persisted).
get_jira_project() {
    local p="${AGENT_SESSION_JIRA_PROJECT:-}"
    [[ -z "$p" ]] && p=$(config_get "$JIRA_PROJECT_KEY")
    if [[ -z "$p" ]]; then
        p=$(jira_prompt "Jira project key (e.g. TEAM)") || {
            echo "Error: no terminal to prompt; set it with '${prog} config jira-project KEY'." >&2
            return 1
        }
        [[ -z "$p" ]] && { echo "Project key is required." >&2; return 1; }
        config_set "$JIRA_PROJECT_KEY" "$p"
    fi
    printf '%s' "$p"
}

# Ticket summary -> git-safe slug (lowercase, non-alphanumeric runs -> '-').
jira_branch_slug() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//'
}

# fzf-pick a ticket from the JSON; echoes the selected KEY (empty if cancelled).
jira_pick_ticket() {
    local json="$1" sel
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required to pick a Jira ticket." >&2
        return 1
    fi
    sel=$(printf '%s' "$json" | jq -r '
        .[] |
        .key + "\t" +
        "[1;34m\(.key)[0m: [1;37m\(.fields.summary)[0m | " +
        "Status: [36m\(.fields.status.name)[0m | " +
        "Type: [35m\(.fields.issuetype.name)[0m | " +
        "Priority: [33m\(.fields.priority.name // "N/A")[0m"
    ' 2>/dev/null | fzf --ansi --no-multi --delimiter=$'\t' --with-nth=2 --prompt="Jira ticket> " || true)
    [[ -z "$sel" ]] && return 0
    printf '%s' "$sel" | cut -d$'\t' -f1
}

# Full ticket details (summary + description) for seeding the agent prompt.
jira_ticket_details() {
    acli jira workitem view "$1" -f summary,description 2>/dev/null || true
}

# Does the ticket already have a branch (local head or cached remote), by prefix?
jira_ticket_has_branch() {
    local prefix="$1" key="$2" hits
    hits=$(git for-each-ref --format='%(refname)' \
        "refs/heads/${prefix}/${key}" "refs/remotes/origin/${prefix}/${key}" 2>/dev/null || true)
    [[ -n "$hits" ]]
}

# Exact branch existence (local or cached remote).
jira_ref_exists() {
    git show-ref --verify --quiet "refs/heads/$1" 2>/dev/null && return 0
    git show-ref --verify --quiet "refs/remotes/origin/$1" 2>/dev/null && return 0
    return 1
}

# Build a UNIQUE ticket branch: <prefix>/<KEY>/<slug>, suffixed -part-N (N>=2) when
# the ticket already has any branch. Echoes the branch name.
jira_unique_branch() {
    local key="$1" slug="$2" prefix base cand n
    prefix=$(get_jira_branch_prefix) || return 1
    base="${prefix}/${key}/${slug}"
    if jira_ticket_has_branch "$prefix" "$key"; then
        n=2; cand="${base}-part-${n}"
        while jira_ref_exists "$cand"; do n=$((n + 1)); cand="${base}-part-${n}"; done
        printf '%s' "$cand"
    else
        printf '%s' "$base"
    fi
}

# Echo a project's existing component names, one per line (empty if none/offline).
jira_project_components() {
    acli jira project view --key "$1" --json 2>/dev/null \
        | jq -r '(.components // .values // [])[]?.name // empty' 2>/dev/null || true
}

# Interactively create a Jira ticket via `acli jira workitem create` (reliable flag
# form). A chosen component is applied as a best-effort follow-up `edit` (acli has no
# component flag), which never fails the creation. Prints key + URL and offers a worktree.
jira_create() {
    if ! command -v jq &>/dev/null; then
        echo "Error: jq is required for '${prog} jira create'." >&2
        return 1
    fi
    if ! printf '' > /dev/tty 2>/dev/null; then
        echo "Error: '${prog} jira create' is interactive and needs a terminal." >&2
        return 1
    fi
    local project type summary description component assignee labels desc_file=""
    project=$(get_jira_project) || return 1

    # Type: fzf-pick a common type (free-text also accepted), else prompt.
    if command -v fzf &>/dev/null; then
        type=$(printf '%s\n' Task Story Bug Epic Spike \
            | fzf --prompt="Type> " --print-query --height=40% --header="Work item type (type to add your own)" 2>/dev/null \
            | tail -1)
    fi
    [[ -z "${type:-}" ]] && type=$(jira_prompt "Type" "Task")
    [[ -z "$type" ]] && type="Task"

    summary=$(jira_prompt "Summary") || return 1
    if [[ -z "$summary" ]]; then
        echo "Summary is required — aborting." >&2
        return 1
    fi

    # Component (optional): choose from the project's existing components (fzf), or
    # type your own, or skip. Falls back to a plain prompt when fzf/components absent.
    local comps
    comps=$(jira_project_components "$project")
    if [[ -n "$comps" ]] && command -v fzf &>/dev/null; then
        component=$( { printf '(none)\n'; printf '%s\n' "$comps"; } \
            | fzf --prompt="Component> " --print-query --height=40% \
                  --header="Component (Enter=skip; type to filter or add a new one)" 2>/dev/null \
            | tail -1)
        [[ "$component" == "(none)" ]] && component=""
    else
        component=$(jira_prompt "Component (optional)" "")
    fi

    # Description: blank to skip, plain text inline, or 'e' to open $EDITOR (passed to
    # acli as --description-file so acli builds the ADF).
    printf 'Description (Enter to skip, text for one line, or "e" to open %s): ' "${EDITOR:-vi}" > /dev/tty 2>/dev/null || true
    IFS= read -r description < /dev/tty || true
    if [[ "$description" == "e" ]]; then
        desc_file="${TMPDIR:-/tmp}/gas-jira-desc.$$"
        : > "$desc_file"
        "${EDITOR:-vi}" "$desc_file" < /dev/tty > /dev/tty 2>&1 || true
        description=""
    fi

    assignee=$(jira_prompt "Assignee (email / @me / blank)" "@me")
    labels=$(jira_prompt "Labels (comma-separated, optional)" "")

    # Create with acli's flags (reliable). The component is applied afterward (below),
    # since acli has no --component flag.
    local args=(jira workitem create --json -p "$project" -t "$type" -s "$summary")
    [[ -n "$desc_file" ]] && args+=(--description-file "$desc_file")
    [[ -z "$desc_file" && -n "$description" ]] && args+=(-d "$description")
    [[ -n "$assignee" ]] && args+=(-a "$assignee")
    [[ -n "$labels" ]] && args+=(-l "$labels")

    echo
    echo "About to create in $project:"
    echo "  Type:      $type"
    echo "  Summary:   $summary"
    [[ -n "$component" ]] && echo "  Component: $component  (set after create)"
    [[ -n "$desc_file" ]] && echo "  Desc:      (from editor)"
    [[ -z "$desc_file" && -n "$description" ]] && echo "  Desc:      $description"
    [[ -n "$assignee" ]] && echo "  Assignee:  $assignee"
    [[ -n "$labels" ]] && echo "  Labels:    $labels"
    if ! confirm "Create this Jira ticket?"; then
        echo "Cancelled."
        [[ -n "$desc_file" ]] && rm -f "$desc_file" 2>/dev/null || true
        return 0
    fi

    local out key
    out=$(acli "${args[@]}" 2>&1) || true
    [[ -n "$desc_file" ]] && rm -f "$desc_file" 2>/dev/null || true
    key=$(printf '%s' "$out" | jq -r '.key // .issueKey // empty' 2>/dev/null || true)
    [[ -z "$key" ]] && key=$(printf '%s' "$out" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | head -1 || true)
    if [[ -z "$key" ]]; then
        echo "Ticket creation failed or key not found. acli output:" >&2
        printf '%s\n' "$out" >&2
        return 1
    fi

    # Best-effort: set the component via a follow-up edit (non-fatal). Kept simple so
    # a failure here never loses the just-created ticket.
    if [[ -n "$component" ]]; then
        local ctmp cout
        ctmp="${TMPDIR:-/tmp}/gas-jira-comp.$$.json"
        jq -n --arg c "$component" '{additionalAttributes: {components: [{name: $c}]}}' > "$ctmp"
        if cout=$(acli jira workitem edit -k "$key" --from-json "$ctmp" 2>&1); then
            echo "Set component: $component"
            rm -f "$ctmp" 2>/dev/null || true
        else
            echo "Warning: created $key but could not set component '$component':" >&2
            printf '  %s\n' "$cout" >&2
            echo "  Payload kept: $ctmp — adjust and retry: acli jira workitem edit -k $key --from-json $ctmp" >&2
        fi
    fi

    local sd=""
    sd=$(config_get "$JIRA_SUBDOMAIN_KEY"); [[ -z "$sd" ]] && sd="${AGENT_SESSION_JIRA_SUBDOMAIN:-}"
    echo "Created $key"
    [[ -n "$sd" ]] && echo "  https://${sd}.atlassian.net/browse/${key}"

    if confirm "Open a worktree window for $key now?"; then
        cmd_jira "$key"
    fi
}

# --- Subcommand: jira ---
# `jira list` prints my open-sprint issues; `jira create` creates one interactively;
# `jira [KEY]` picks (or uses KEY) and opens a worktree window on a fresh
# ticket-named branch, seeded with the ticket.
cmd_jira() {
    jira_require_acli || return 1
    local sub="${1:-}"

    if [[ "$sub" == "create" || "$sub" == "new" ]]; then
        jira_create
        return $?
    fi

    if [[ "$sub" == "list" || "$sub" == "mine" || "$sub" == "sprint" ]]; then
        local sd json
        sd=$(get_jira_subdomain) || return 1
        json=$(jira_fetch_sprint_json)
        if [[ -z "$json" || "$json" == "[]" ]]; then
            echo "No Jira issues assigned to you in open sprints."
            return 0
        fi
        echo "###########################################################"
        echo "#   Jira Issues Assigned to You in Open Sprints"
        echo "###########################################################"
        echo ""
        printf '%s' "$json" | JIRA_INSTANCE_SUBDOMAIN="$sd" jq -r '
            .[] |
            "[1;34m\(.key)[0m: [1;37m\(.fields.summary)[0m\n" +
            "Status: [36m\(.fields.status.name)[0m | " +
            "Type: [35m\(.fields.issuetype.name)[0m | " +
            "Priority: [33m\(.fields.priority.name // "N/A")[0m\n" +
            "Assignee: [32m\(.fields.assignee.displayName // "Unassigned")[0m\n" +
            "URL: [4;36mhttps://" + (env.JIRA_INSTANCE_SUBDOMAIN) + ".atlassian.net/browse/" + .key + "[0m\n" +
            "-----------------------------------------------------------"
        ' 2>/dev/null || echo "(failed to format issues)"
        return 0
    fi

    # Default: pick (or use KEY arg) -> worktree window seeded with the ticket.
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: Not in a git repository." >&2
        return 1
    fi
    local json key summary slug bn base details tmp prompt_line self
    json=$(jira_fetch_sprint_json)
    if [[ -z "$json" || "$json" == "[]" ]]; then
        echo "No Jira issues assigned to you in open sprints."
        return 0
    fi
    if [[ -n "$sub" ]]; then
        key="$sub"
    else
        key=$(jira_pick_ticket "$json") || return 1
    fi
    if [[ -z "$key" ]]; then
        echo "No ticket selected."
        return 0
    fi
    summary=$(printf '%s' "$json" | jq -r --arg k "$key" '.[] | select(.key == $k) | .fields.summary' 2>/dev/null)
    [[ -z "$summary" ]] && summary=$(jira_ticket_details "$key" | head -1)
    if [[ -z "$summary" ]]; then
        echo "Error: could not resolve a summary for $key." >&2
        return 1
    fi
    slug=$(jira_branch_slug "$summary")
    bn=$(jira_unique_branch "$key" "$slug") || return 1
    base="${AGENT_SESSION_DEV_BRANCH:-develop}"

    # Seed prompt: flattened to a single line (send-keys types it, then C-Enter —
    # embedded newlines would submit prematurely).
    details=$(jira_ticket_details "$key")
    prompt_line=$(printf '%s: %s. %s' "$key" "$summary" "$details" | tr '\n\r\t' '   ' | tr -s ' ')
    tmp="${TMPDIR:-/tmp}/gas-jira-${key}.$$"
    printf '%s\n' "$prompt_line" > "$tmp" 2>/dev/null || tmp=""

    self=$(resolve_self)
    echo "Jira $key → worktree branch: $bn  (base: $base)"
    if [[ -n "$tmp" ]]; then
        "$self" new --worktree --branch "$base" --branch-name "$bn" -n "$key" --ticket "$key" --prompt-file "$tmp"
        rm -f "$tmp" 2>/dev/null || true
    else
        "$self" new --worktree --branch "$base" --branch-name "$bn" -n "$key" --ticket "$key" -- "$prompt_line"
    fi
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

    # Claude sessions for this worktree (file count + last-active; contents unread).
    if [[ -n "$path" ]] && [[ -d "$path" ]]; then
        local csess
        csess=$(claude_sessions_summary "$path")
        echo "Claude sessions: ${csess:-none}"
        echo
    fi

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

# --- Subcommand: sessions (list a worktree's Claude sessions) ---
cmd_sessions() {
    local path="${1:-}"
    [[ -z "$path" || "$path" == "-" ]] && path=$(pwd)
    if [[ ! -d "$path" ]]; then
        echo "Error: not a directory: $path" >&2
        exit 1
    fi
    local pdir files
    pdir=$(claude_project_dir "$path")
    files=$(claude_session_files "$path")
    echo "Claude sessions for: $path"
    echo "Project dir: $pdir"
    if [[ -z "$files" ]]; then
        echo "  (none yet)"
        return 0
    fi
    local now f id mt age
    now=$(date +%s)
    printf '%s\n' "$files" | while IFS= read -r f; do
        [[ -z "$f" ]] && continue
        id=$(basename "$f" .jsonl)
        mt=$(stat -f %m "$f" 2>/dev/null || echo "")
        if [[ -n "$mt" ]]; then age=$(rel_age $((now - mt))); else age="?"; fi
        printf '  %s  (last active %s)\n' "$id" "$age"
    done
    echo
    echo "Resume latest:  (cd $(printf '%q' "$path") && claude --continue)"
    echo "Pick a session: (cd $(printf '%q' "$path") && claude --resume)"
}

# Emit "PATH<TAB>LABEL" rows for the editable agent-config files of a project, for the
# given ecosystem: claude (skills/subagents/CLAUDE.md), cursor (.cursor/rules/*.mdc +
# .cursorrules — Cursor has no file-based skills/subagents), or both. Only existing
# files are listed; globs are guarded (bash has no nullglob by default).
agent_config_rows() {
    local eco="$1" proj="$2" f d
    if [[ "$eco" == claude || "$eco" == both ]]; then
        [[ -f "$proj/CLAUDE.md" ]]        && printf '%s\trule · project · CLAUDE.md\n' "$proj/CLAUDE.md"
        [[ -f "$proj/CLAUDE.local.md" ]]  && printf '%s\trule · project · CLAUDE.local.md\n' "$proj/CLAUDE.local.md"
        [[ -f "$HOME/.claude/CLAUDE.md" ]] && printf '%s\trule · global · CLAUDE.md\n' "$HOME/.claude/CLAUDE.md"
        for d in "$proj"/.claude/skills/*/SKILL.md;  do [[ -f "$d" ]] && printf '%s\tskill · project · %s\n' "$d" "$(basename "$(dirname "$d")")"; done
        for d in "$HOME"/.claude/skills/*/SKILL.md;   do [[ -f "$d" ]] && printf '%s\tskill · global · %s\n' "$d" "$(basename "$(dirname "$d")")"; done
        for f in "$proj"/.claude/agents/*.md;         do [[ -f "$f" ]] && printf '%s\tsubagent · project · %s\n' "$f" "$(basename "$f" .md)"; done
        for f in "$HOME"/.claude/agents/*.md;         do [[ -f "$f" ]] && printf '%s\tsubagent · global · %s\n' "$f" "$(basename "$f" .md)"; done
    fi
    if [[ "$eco" == cursor || "$eco" == both ]]; then
        for f in "$proj"/.cursor/rules/*.mdc;         do [[ -f "$f" ]] && printf '%s\trule · project · %s\n' "$f" "$(basename "$f")"; done
        [[ -f "$proj/.cursorrules" ]] && printf '%s\trule · project · .cursorrules\n' "$proj/.cursorrules"
    fi
}

# --- Subcommand: edit (fzf-pick a skill/rule/subagent and open it in $EDITOR) ---
# Ecosystem follows the configured harness: claude surfaces skills + subagents +
# CLAUDE.md; cursor surfaces .cursor/rules/*.mdc + .cursorrules; anything else shows both.
# Echo the editor to use: $VISUAL, then $EDITOR, then the first common editor found.
# Returns non-zero (empty) if nothing is available.
resolve_editor() {
    local editor="${VISUAL:-${EDITOR:-}}" e
    if [[ -z "$editor" ]]; then
        for e in nvim vim vi nano; do command -v "$e" &>/dev/null && { editor="$e"; break; }; done
    fi
    [[ -z "$editor" ]] && return 1
    printf '%s' "$editor"
}

cmd_edit() {
    if ! command -v fzf &>/dev/null; then
        echo "Error: fzf is required for '${prog} edit'." >&2
        return 1
    fi
    local proj eco h rows editor sel path
    proj=$(git rev-parse --show-toplevel 2>/dev/null || pwd)
    if default_harness_is_claude; then
        eco=claude
    else
        h="${AGENT_SESSION_HARNESS_COMMAND:-}"; [[ -z "$h" ]] && h=$(config_get "$HARNESS_KEY")
        case "${h%% *}" in
            cursor|cursor-agent) eco=cursor ;;
            *) eco=both ;;
        esac
    fi
    rows=$(agent_config_rows "$eco" "$proj")
    if [[ -z "$rows" ]]; then
        echo "No editable agent config found for $proj ($eco)."
        echo "Claude: .claude/skills/<name>/SKILL.md, .claude/agents/*.md, CLAUDE.md" >&2
        echo "Cursor: .cursor/rules/*.mdc, .cursorrules" >&2
        return 0
    fi
    # Resolve the editor: $VISUAL/$EDITOR, else the first available common terminal editor.
    editor=$(resolve_editor) || { echo "No editor found. Set \$EDITOR (e.g. export EDITOR=nvim)." >&2; return 1; }
    sel=$(printf '%s' "$rows" | fzf --ansi --no-multi --delimiter=$'\t' --with-nth=2 \
        --prompt="edit ($eco)> " \
        --header="Open a skill / rule / subagent in $editor" \
        --preview='cat {1} 2>/dev/null | head -200' --preview-window='right,60%,wrap' || true)
    [[ -z "$sel" ]] && return 0
    path=$(printf '%s' "$sel" | cut -f1)
    [[ -z "$path" ]] && return 0
    "$editor" "$path"
}

# =====================================================================================
# gas note: simple per-user note files, managed like `gas install` — via flags or an
# fzf menu. Notes are plain markdown files under $AGENT_SESSION_NOTES
# (default ~/.config/agent-session/notes).
# =====================================================================================
get_notes_dir() {
    # cmd_note sets _note_dir_override when --project is used; otherwise global.
    echo "${_note_dir_override:-${AGENT_SESSION_NOTES:-$HOME/.config/agent-session/notes}}"
}

# echo the per-project notes dir (<global>/proj/<repo-slug>); non-zero if not in a repo.
# Uses --git-common-dir so a linked worktree resolves to its MAIN repo (shared notes).
note_project_dir() {
    local common root slug base
    common=$(git rev-parse --git-common-dir 2>/dev/null) || return 1
    [[ -z "$common" ]] && return 1
    case "$common" in /*) ;; *) common="$(pwd)/$common" ;; esac   # make absolute
    root=$(cd "$(dirname "$common")" 2>/dev/null && pwd -P) || return 1
    slug=$(note_slug "$(basename "$root")"); [[ -z "$slug" ]] && slug="repo"
    base="${AGENT_SESSION_NOTES:-$HOME/.config/agent-session/notes}"
    printf '%s/proj/%s' "$base" "$slug"
}

# true when there is a terminal to prompt on / drive fzf (same probe style as confirm)
have_tty() { { true >/dev/tty; } 2>/dev/null; }

# Echo the note body per the --body/stdin rules. $1=body_set(1/empty) $2=body value.
#   --body given: value ('-' means read stdin); else if stdin is piped, read stdin; else none.
read_note_body() {
    local body_set="${1:-}" body_val="${2:-}"
    if [[ -n "$body_set" ]]; then
        if [[ "$body_val" == "-" ]]; then cat; else printf '%s' "$body_val"; fi
    elif [[ ! -t 0 ]]; then
        cat
    fi
}

# slugify a title into a filesystem-friendly base name (lowercase, dashes)
note_slug() {
    printf '%s' "$1" | tr '[:upper:]' '[:lower:]' \
        | sed -e 's/[^a-z0-9]\{1,\}/-/g' -e 's/^-*//' -e 's/-*$//'
}

# echo note file paths, newest first (existing dir only)
notes_list() {
    local d f; d=$(get_notes_dir)
    [[ -d "$d" ]] || return 0
    ls -t "$d" 2>/dev/null | while IFS= read -r f; do
        [[ -n "$f" && -f "$d/$f" ]] && printf '%s\n' "$d/$f"
    done
}

# resolve a note NAME (with/without .md, or its slug) to a path; non-zero if not found
note_resolve() {
    local d name slug; d=$(get_notes_dir); name="${1:-}"
    [[ -z "$name" ]] && return 1
    [[ -f "$d/$name" ]]     && { printf '%s' "$d/$name"; return 0; }
    [[ -f "$d/$name.md" ]]  && { printf '%s' "$d/$name.md"; return 0; }
    slug=$(note_slug "$name")
    [[ -n "$slug" && -f "$d/$slug.md" ]] && { printf '%s' "$d/$slug.md"; return 0; }
    return 1
}

# fzf-pick an existing note; echo its path (non-zero if none / cancelled)
note_pick() {
    local rows sel
    rows=$(notes_list)
    if [[ -z "$rows" ]]; then echo "No notes yet. Create one with '${prog} note --new TITLE'." >&2; return 1; fi
    if ! command -v fzf &>/dev/null; then echo "Error: fzf required to pick a note (or pass its NAME)." >&2; return 1; fi
    sel=$(printf '%s\n' "$rows" | fzf --ansi --no-multi --delimiter=/ --with-nth=-1 \
        --prompt="${1:-note}> " --header="${2:-Select a note}" \
        --preview='cat {} 2>/dev/null | head -200' --preview-window='right,60%,wrap' || true)
    [[ -z "$sel" ]] && return 1
    printf '%s' "$sel"
}

# resolve a target note from an optional NAME, else fzf-pick; echo path
note_target() {
    local name="${1:-}" path
    if [[ -n "$name" ]]; then
        path=$(note_resolve "$name") || { echo "No note matching '$name'. Try '${prog} note --list'." >&2; return 1; }
    else
        if ! have_tty; then
            echo "Error: no NAME given and no terminal for the picker. Pass a NAME, or use '${prog} note --search TERM' / '${prog} note --list'." >&2
            return 1
        fi
        path=$(note_pick) || return 1
    fi
    printf '%s' "$path"
}

# note_new TITLE [body_set] [body_val] [no_edit] [quiet]
# Body comes from --body (body_val, '-'=stdin) or piped stdin; editor only opens when
# interactive AND no body was supplied (preserves the human default). Never clobbers.
note_new() {
    local title="$1" body_set="${2:-}" body_val="${3:-}" no_edit="${4:-}" quiet="${5:-}"
    local d slug path editor body have_body=""
    if [[ -z "$title" ]]; then echo "Usage: ${prog} note --new <title>" >&2; return 1; fi
    d=$(get_notes_dir); mkdir -p "$d"
    slug=$(note_slug "$title"); [[ -z "$slug" ]] && slug="note"
    path="$d/$slug.md"

    body=$(read_note_body "$body_set" "$body_val")
    [[ -n "$body_set" || ! -t 0 ]] && have_body=1

    if [[ -e "$path" ]]; then
        if [[ -n "$have_body" ]]; then
            echo "Error: note already exists: $path. Use '${prog} note --append $slug' to add to it." >&2
            return 1
        fi
        [[ -z "$quiet" ]] && echo "Note already exists: $path (opening it)."
    else
        if [[ -n "$body" ]]; then printf '# %s\n\n%s\n' "$title" "$body" > "$path"
        else printf '# %s\n\n' "$title" > "$path"; fi
        [[ -z "$quiet" ]] && echo "Created $path"
    fi

    # Non-interactive (body supplied, --no-edit, or no terminal) => don't open an editor.
    if [[ -n "$have_body" || -n "$no_edit" ]] || ! have_tty; then
        [[ -n "$quiet" ]] && printf '%s\n' "$path"
        return 0
    fi
    editor=$(resolve_editor) || { echo "No editor found. Set \$EDITOR (e.g. export EDITOR=nvim)." >&2; return 0; }
    "$editor" "$path"
}

# note_append NAME [body_set] [body_val] [quiet] — append stdin/--body; auto-create if missing.
note_append() {
    local name="$1" body_set="${2:-}" body_val="${3:-}" quiet="${4:-}"
    local d path body
    if [[ -z "$name" ]]; then echo "Usage: ${prog} note --append <name>  (body via --body or stdin)" >&2; return 1; fi
    if [[ -z "$body_set" && -t 0 ]]; then
        echo "Error: nothing to append. Pass --body TEXT or pipe content on stdin." >&2; return 1
    fi
    body=$(read_note_body "$body_set" "$body_val")
    path=$(note_resolve "$name" || true)
    if [[ -z "$path" ]]; then                 # auto-create
        d=$(get_notes_dir); mkdir -p "$d"
        local slug; slug=$(note_slug "$name"); [[ -z "$slug" ]] && slug="note"
        path="$d/$slug.md"
        printf '# %s\n\n' "$name" > "$path"
    fi
    # ensure a newline boundary, then append body + trailing newline
    [[ -s "$path" && -n "$(tail -c1 "$path" 2>/dev/null)" ]] && printf '\n' >> "$path"
    printf '%s\n' "$body" >> "$path"
    [[ -z "$quiet" ]] && echo "Appended to $path"
    [[ -n "$quiet" ]] && printf '%s\n' "$path"
    return 0
}

# note_search TERM — grep all notes; print '<note>:<line>:<match>' (basename), token-frugal.
note_search() {
    local term="$1" rows p base hit found=""
    if [[ -z "$term" ]]; then echo "Usage: ${prog} note --search <term>" >&2; return 1; fi
    rows=$(notes_list)
    [[ -z "$rows" ]] && return 1
    while IFS= read -r p; do
        [[ -z "$p" ]] && continue
        base=$(basename "$p")
        hit=$(grep -niIF -- "$term" "$p" 2>/dev/null || true)
        [[ -z "$hit" ]] && continue
        found=1
        printf '%s\n' "$hit" | while IFS= read -r line; do printf '%s:%s\n' "$base" "$line"; done
    done <<< "$rows"
    [[ -n "$found" ]]
}

# note_path [NAME] — print just the resolved absolute path (agent then reads with offsets).
note_path() {
    local path; path=$(note_target "${1:-}") || return 1
    printf '%s\n' "$path"
}

note_edit() {
    local path editor
    path=$(note_target "${1:-}") || return 1
    editor=$(resolve_editor) || { echo "No editor found. Set \$EDITOR (e.g. export EDITOR=nvim)." >&2; return 1; }
    "$editor" "$path"
}

note_cat() {
    local path; path=$(note_target "${1:-}") || return 1
    cat "$path"
}

# note_delete [NAME] [assume_yes] — --yes/-y bypasses the confirm (for agents).
note_delete() {
    local path; path=$(note_target "${1:-}") || return 1
    if [[ -n "${2:-}" ]] || confirm "Delete note '$(basename "$path")'?"; then
        rm -f "$path" && echo "Deleted $path" || echo "Could not delete $path"
    else
        echo "Cancelled."
    fi
}

# emit one SEP-delimited row per note: name<US>path<US>title<US>bytes<US>lines
note_emit_rows() {
    local SEP=$'\037' rows p title bytes lines
    rows=$(notes_list)
    [[ -z "$rows" ]] && return 0
    while IFS= read -r p; do
        [[ -z "$p" ]] && continue
        title=$(head -1 "$p" 2>/dev/null | sed 's/^#\{1,\} *//')
        bytes=$(wc -c < "$p" 2>/dev/null | tr -d ' '); [[ -z "$bytes" ]] && bytes=0
        lines=$(wc -l < "$p" 2>/dev/null | tr -d ' '); [[ -z "$lines" ]] && lines=0
        printf '%s%s%s%s%s%s%s%s%s\n' "$(basename "$p")" "$SEP" "$p" "$SEP" "$title" "$SEP" "$bytes" "$SEP" "$lines"
    done <<< "$rows"
}

# note_list_pretty [json] — table by default; compact JSON array when $1 is set (like cmd_system)
note_list_pretty() {
    local want_json="${1:-}" rows
    rows=$(notes_list)
    if [[ -z "$rows" ]]; then
        [[ -n "$want_json" ]] && { echo "[]"; return 0; }
        echo "No notes yet. Create one with '${prog} note --new TITLE'."; return 0
    fi
    if [[ -n "$want_json" ]] && command -v jq &>/dev/null; then
        note_emit_rows | jq -R -s '
            split("\n") | map(select(length > 0)) | map(split("\u001f")) | map({
                name: .[0], path: .[1], title: .[2],
                bytes: (.[3] | tonumber? // 0), lines: (.[4] | tonumber? // 0) })'
        return 0
    fi
    # table fallback (also used when jq is absent even if --json was asked)
    local name path title bytes lines
    note_emit_rows | while IFS=$'\037' read -r name path title bytes lines; do
        [[ -z "$name" ]] && continue
        printf '  %-32s %6sB  %s\n' "$name" "$bytes" "${title:0:50}"
    done
}

# ctrl-a-style actions menu for a single note; returns 0 so the caller reloops
note_actions_menu() {
    local path="$1" choice editor
    choice=$(printf '%s\n' "Edit" "Cat" "Delete" \
        | fzf --no-multi --prompt='action> ' --header="Actions: $(basename "$path")" || true)
    [[ -z "$choice" ]] && return 0
    case "$choice" in
        Edit)   editor=$(resolve_editor) || { echo "No editor found. Set \$EDITOR."; pause_for_key; return 0; }
                "$editor" "$path" ;;
        Cat)    cat "$path"; pause_for_key ;;
        Delete) if confirm "Delete '$(basename "$path")'?"; then
                    rm -f "$path" && echo "Deleted." || echo "Delete failed."
                else echo "Cancelled."; fi
                pause_for_key ;;
    esac
    return 0
}

# fzf menu over all notes; Enter opens the per-note actions menu
note_menu() {
    if ! command -v fzf &>/dev/null; then echo "Error: fzf is required for the '${prog} note' menu (or use flags)." >&2; return 1; fi
    while true; do
        local rows sel; rows=$(notes_list)
        if [[ -z "$rows" ]]; then
            echo "No notes yet. Create one with '${prog} note --new TITLE'."
            return 0
        fi
        sel=$(printf '%s\n' "$rows" | fzf --ansi --no-multi --delimiter=/ --with-nth=-1 \
            --header='enter: actions (edit / cat / delete)' \
            --preview='cat {} 2>/dev/null | head -200' --preview-window='right,60%,wrap' || true)
        [[ -z "$sel" ]] && return 0
        note_actions_menu "$sel"
    done
}

note_usage() {
    cat >&2 <<EOF
Usage:
  ${prog} note --new <title> [--body TEXT|-] [--no-edit]   create a note (opens \$EDITOR if
                                                            interactive and no body given)
  ${prog} note --append <name> [--body TEXT|-]             append --body/stdin (auto-creates)
  ${prog} note --edit [NAME]                               edit a note (fzf-pick if omitted)
  ${prog} note --cat [NAME]                                print a note
  ${prog} note --path [NAME]                               print just the note's file path
  ${prog} note --search <term>                             grep all notes -> name:line:match
  ${prog} note --delete [NAME] [--yes]                     delete (--yes skips the prompt)
  ${prog} note --list [--json]                             list notes (JSON incl. bytes/lines)
  ${prog} note                                             fzf menu -> edit / cat / delete
Flags: --project|-p scope to the current repo · --global · --quiet|-q · --body - reads stdin.
Notes live in \$AGENT_SESSION_NOTES (default ~/.config/agent-session/notes).
EOF
}

# --- Subcommand: note (flag-driven; positional is a note name / title / search term) ---
cmd_note() {
    local mode="" body_set="" body_val="" want_json="" no_edit="" assume_yes="" quiet="" project=""
    local pos=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --new|--create)  mode="new"; shift ;;
            --append|--add)  mode="append"; shift ;;
            --edit)          mode="edit"; shift ;;
            --cat|--show)    mode="cat"; shift ;;
            --path)          mode="path"; shift ;;
            --search|--grep) mode="search"; shift ;;
            --delete|--rm)   mode="delete"; shift ;;
            --list|--ls)     mode="list"; shift ;;
            --menu)          mode="menu"; shift ;;
            --body)          body_set=1; body_val="${2:-}"; shift 2 ;;
            --json)          want_json=1; shift ;;
            --no-edit)       no_edit=1; shift ;;
            --yes|-y)        assume_yes=1; shift ;;
            --quiet|-q)      quiet=1; shift ;;
            --project|-p)    project=1; shift ;;
            --global)        project=""; shift ;;
            -h|--help)       note_usage; return 0 ;;
            --)              shift; while [[ $# -gt 0 ]]; do pos+=("$1"); shift; done ;;
            -*)              echo "Error: unknown flag '$1'." >&2; note_usage; return 1 ;;
            *)               pos+=("$1"); shift ;;
        esac
    done

    # --project: point every note helper at the per-repo dir via the override var.
    if [[ -n "$project" ]]; then
        _note_dir_override=$(note_project_dir) || {
            echo "Error: --project requires being inside a git repository." >&2; return 1; }
    fi

    local name="" title="" term=""
    if [[ ${#pos[@]} -gt 0 ]]; then name="${pos[0]}"; title="${pos[*]}"; term="${pos[*]}"; fi

    case "$mode" in
        new)     note_new "$title" "$body_set" "$body_val" "$no_edit" "$quiet" ;;
        append)  note_append "$name" "$body_set" "$body_val" "$quiet" ;;
        edit)    note_edit "$name" ;;
        cat)     note_cat "$name" ;;
        path)    note_path "$name" ;;
        search)  note_search "$term" ;;
        delete)  note_delete "$name" "$assume_yes" ;;
        list)    note_list_pretty "$want_json" ;;
        menu|"")
            # bare 'note' -> menu; 'note NAME' with no flag -> edit that note.
            if [[ -n "$name" ]]; then note_edit "$name"; else note_menu; fi
            ;;
    esac
}

# =====================================================================================
# gas install: track globally-installed CLI tools across package managers.
# Registry line: name|manager|version|installed_iso|source|bin|uninstall
#   manager  = brew|cargo|pip|apt|curl
#   source   = package name (managers) or the URL (curl)
#   bin      = optional binary path (curl removes), uninstall = optional remove cmd (curl)
# =====================================================================================
get_installs_file() {
    echo "${AGENT_SESSION_INSTALLS:-$HOME/.config/agent-session/installs}"
}

installs_remove() {
    local f tmp
    f=$(get_installs_file); [[ -f "$f" ]] || return 0
    tmp="${f}.tmp.$$"
    grep -v "^${1}|" "$f" > "$tmp" 2>/dev/null || true
    mv "$tmp" "$f"
}

# installs_add name manager version source [bin] [uninstall]  (replaces any same-name row)
installs_add() {
    local f
    f=$(get_installs_file); mkdir -p "$(dirname "$f")"
    installs_remove "$1"
    printf '%s|%s|%s|%s|%s|%s|%s\n' \
        "$1" "$2" "$3" "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$4" "${5:-}" "${6:-}" >> "$f"
}

installs_list() {  # echo raw registry lines (existing file only)
    local f; f=$(get_installs_file)
    [[ -f "$f" ]] && cat "$f" || true
}

# --- Per-manager command table (bash 3.2: case, no assoc arrays) ---
pkg_bin() { case "$1" in brew) echo brew ;; cargo) echo cargo ;; pip) echo pip3 ;; apt) echo apt-get ;; curl) echo curl ;; esac; }
pkg_available() { command -v "$(pkg_bin "$1")" &>/dev/null; }

pkg_install() {  # $1=manager $2=pkg  (curl handled in install_do)
    case "$1" in
        brew)  brew install "$2" ;;
        cargo) cargo install "$2" ;;
        pip)   pip3 install --user "$2" ;;
        apt)   sudo apt-get install -y "$2" ;;
        *)     return 1 ;;
    esac
}
pkg_update() {  # $1=manager $2=name
    case "$1" in
        brew)  brew upgrade "$2" ;;
        cargo) cargo install --force "$2" ;;
        pip)   pip3 install --user --upgrade "$2" ;;
        apt)   sudo apt-get install --only-upgrade -y "$2" ;;
        *)     return 1 ;;
    esac
}
pkg_remove() {  # $1=manager $2=name
    case "$1" in
        brew)  brew uninstall "$2" ;;
        cargo) cargo uninstall "$2" ;;
        pip)   pip3 uninstall -y "$2" ;;
        apt)   sudo apt-get remove -y "$2" ;;
        *)     return 1 ;;
    esac
}
pkg_installed_version() {  # echo the currently-installed version, or empty
    case "$1" in
        brew)  brew list --versions "$2" 2>/dev/null | awk '{print $2; exit}' ;;
        cargo) cargo install --list 2>/dev/null | awk -v n="$2" '$1==n{gsub(/[v:]/,"",$2); print $2; exit}' ;;
        pip)   pip3 show "$2" 2>/dev/null | awk -F': ' '/^Version/{print $2; exit}' ;;
        apt)   dpkg-query -W -f='${Version}' "$2" 2>/dev/null ;;
        *)     echo "" ;;
    esac
}
pkg_latest_version() {  # echo the latest available version (on-demand; may hit network)
    case "$1" in
        brew)  brew info --json=v2 --formula "$2" 2>/dev/null | jq -r '.formulae[0].versions.stable // empty' 2>/dev/null ;;
        pip)   pip3 index versions "$2" 2>/dev/null | awk -F': ' '/LATEST/{print $2; exit}' ;;
        cargo) curl -fsSL "https://crates.io/api/v1/crates/$2" 2>/dev/null | jq -r '.crate.max_stable_version // empty' 2>/dev/null ;;
        apt)   apt-cache policy "$2" 2>/dev/null | awk '/Candidate:/{print $2; exit}' ;;
        *)     echo "" ;;
    esac
}
# List the names of packages this manager reports as explicitly/top-level installed
# (not pulled-in dependencies), one per line. curl has no such notion (empty).
pkg_discover() {
    case "$1" in
        brew)  brew leaves 2>/dev/null ;;                                   # top-level formulae only
        cargo) cargo install --list 2>/dev/null | awk '/^[^[:space:]]/{print $1}' ;;  # crate names
        pip)   pip3 list --user --format=freeze 2>/dev/null | sed 's/==.*//' ;;       # user-site pkgs
        apt)   apt-mark showmanual 2>/dev/null ;;                           # manually-installed
        *)     : ;;
    esac
}

# --- install: `gas install <pkg> [--MGR]` | `--curl URL NAME` | `--list` | `--outdated` ---
install_usage() {
    cat >&2 <<EOF
Usage:
  ${prog} install <pkg> [--brew|--cargo|--pip|--apt]   install & track a tool
                                                       (no manager flag = auto: brew -> cargo -> pip -> apt)
  ${prog} install --curl <URL> <NAME> [--bin PATH] [--uninstall CMD]
                                                       install via curl | bash and track it
  ${prog} install --discover [--brew|--cargo|--pip|--apt] [-n]
                                                       import already-installed tools into tracking
                                                       (all available managers if none named; -n = dry run)
  ${prog} install --list                               list tracked tools
  ${prog} install --outdated                           check tracked tools for updates
  ${prog} install                                      fzf menu to update / check / remove
EOF
}

# --- list (fast; from the registry) ---
install_list() {
    local rows
    rows=$(installs_list)
    if [[ -z "$rows" ]]; then echo "No tracked installs. Add one with '${prog} install <pkg>'."; return 0; fi
    printf "%-24s %-7s %-16s %s\n" "NAME" "MANAGER" "VERSION" "SOURCE"
    printf "%-24s %-7s %-16s %s\n" "----" "-------" "-------" "------"
    local name mgr ver iso src rest
    while IFS='|' read -r name mgr ver iso src rest; do
        [[ -z "$name" ]] && continue
        printf "%-24s %-7s %-16s %s\n" "${name:0:24}" "$mgr" "${ver:0:16}" "${src:0:40}"
    done <<< "$rows"
}

# --- outdated (on-demand latest-version check per manager) ---
install_outdated() {
    local rows; rows=$(installs_list)
    if [[ -z "$rows" ]]; then echo "No tracked installs."; return 0; fi
    echo "Checking latest versions (this may hit the network)..."
    local name mgr ver iso src rest cur latest
    while IFS='|' read -r name mgr ver iso src rest; do
        [[ -z "$name" ]] && continue
        if [[ "$mgr" == curl ]]; then
            printf '  %-24s %-7s n/a (curl — re-run to update)\n' "$name" "$mgr"; continue
        fi
        cur=$(pkg_installed_version "$mgr" "$name" || true); [[ -z "$cur" ]] && cur="$ver"
        latest=$(pkg_latest_version "$mgr" "$name" || true)
        if [[ -z "$latest" ]]; then
            printf '  %-24s %-7s %s (latest unknown)\n' "$name" "$mgr" "${cur:-?}"
        elif [[ "$latest" == "$cur" ]]; then
            printf '  %-24s %-7s %s (up to date)\n' "$name" "$mgr" "${cur:-?}"
        else
            printf '  %-24s %-7s %s -> %s  ** OUTDATED **\n' "$name" "$mgr" "${cur:-?}" "$latest"
        fi
    done <<< "$rows"
}

# --- discover: retroactively track tools already installed via each manager ---
# $1 = optional single manager (else all available); $2 = 1 for dry-run (preview only)
install_discover() {
    local want="${1:-}" dry="${2:-}"
    local managers m
    if [[ -n "$want" ]]; then
        if [[ "$want" == curl ]]; then
            echo "Error: curl installs can't be discovered (no manager to query)." >&2; return 1
        fi
        managers="$want"
    else
        managers="brew cargo pip apt"
    fi
    local tracked; tracked=$(installs_list | cut -d'|' -f1)
    local total=0 added=0 skipped=0 name ver names
    for m in $managers; do
        if ! pkg_available "$m"; then
            [[ -n "$want" ]] && echo "  ($m is not installed)"
            continue
        fi
        names=$(pkg_discover "$m" || true)
        [[ -z "$names" ]] && continue
        echo "== $m =="
        while IFS= read -r name; do
            [[ -z "$name" ]] && continue
            total=$((total + 1))
            if printf '%s\n' "$tracked" | grep -qxF "$name"; then
                skipped=$((skipped + 1)); continue
            fi
            ver=$(pkg_installed_version "$m" "$name" 2>/dev/null || true)
            if [[ -n "$dry" ]]; then
                printf '  ? %-28s %s\n' "$name" "${ver:+($ver)}"
            else
                installs_add "$name" "$m" "$ver" "$name" "" ""
                printf '  + %-28s %s\n' "$name" "${ver:+($ver)}"
            fi
            added=$((added + 1))
            tracked="$tracked
$name"   # so a tool present in two managers is only imported once
        done <<< "$names"
    done
    if [[ -n "$dry" ]]; then
        echo "Found $total (${added} not yet tracked, ${skipped} already tracked). Dry run — nothing imported."
    else
        echo "Found $total, imported $added new, skipped $skipped already-tracked."
    fi
}

# --- ctrl-a-style actions menu for a tracked install; returns 0 (caller reloops) ---
install_actions_menu() {
    local name="$1" mgr="$2" src="$3" bin="$4" uninstall="$5"
    local choice
    choice=$(printf '%s\n' \
        "Update" "Check latest version" "Remove" "Copy source" \
        | fzf --no-multi --prompt='action> ' --header="Actions: $name [$mgr]" || true)
    [[ -z "$choice" ]] && return 0
    case "$choice" in
        "Update"*)
            echo "Updating $name ($mgr) ..."
            if [[ "$mgr" == curl ]]; then
                curl -fsSL "$src" | bash || echo "Re-run failed."
            else
                pkg_update "$mgr" "$name" || echo "Update failed."
                installs_add "$name" "$mgr" "$(pkg_installed_version "$mgr" "$name")" "$src" "$bin" "$uninstall"
            fi
            pause_for_key
            ;;
        "Check latest"*)
            if [[ "$mgr" == curl ]]; then
                echo "$name: curl install — version is n/a (re-run the script to update)."
            else
                local cur latest; cur=$(pkg_installed_version "$mgr" "$name" || true); latest=$(pkg_latest_version "$mgr" "$name" || true)
                echo "$name ($mgr): installed ${cur:-?}, latest ${latest:-unknown}"
                [[ -n "$latest" && -n "$cur" && "$latest" != "$cur" ]] && echo "  ** update available **"
            fi
            pause_for_key
            ;;
        "Remove"*)
            if confirm "Remove '$name' ($mgr)?"; then
                if [[ "$mgr" == curl ]]; then
                    if [[ -n "$uninstall" ]]; then bash -c "$uninstall" || echo "uninstall cmd failed."
                    elif [[ -n "$bin" ]]; then rm -f "$bin" && echo "Removed $bin" || echo "Could not remove $bin"
                    else echo "curl install has no --uninstall/--bin recorded; removing from tracking only (delete the binary manually)."; fi
                else
                    pkg_remove "$mgr" "$name" || echo "Remove failed (unregistering anyway)."
                fi
                installs_remove "$name"
                echo "Removed $name from tracking."
            else
                echo "Cancelled."
            fi
            pause_for_key
            ;;
        "Copy source"*)
            if command -v pbcopy &>/dev/null; then printf '%s' "$src" | pbcopy && echo "Copied: $src"
            else echo "Source: $src"; fi
            pause_for_key
            ;;
    esac
    return 0
}

# --- menu (fzf list of tracked installs + actions) ---
install_menu() {
    if ! command -v fzf &>/dev/null; then echo "Error: fzf is required for '${prog} install' (the menu)." >&2; return 1; fi
    while true; do
        local rows; rows=$(installs_list)
        if [[ -z "$rows" ]]; then
            echo "No tracked installs. Add one with '${prog} install <pkg>'."
            return 0
        fi
        local sel
        sel=$(printf '%s' "$rows" | fzf --no-multi --delimiter='|' --with-nth=1,2,3 \
            --header='enter: actions (update / check / remove)   ·   name | manager | version' \
            --preview='echo "source: {5}"; echo "installed: {3}"' --preview-window='down,3,wrap' || true)
        [[ -z "$sel" ]] && return 0
        local name mgr ver iso src bin uninstall
        IFS='|' read -r name mgr ver iso src bin uninstall <<< "$sel"
        install_actions_menu "$name" "$mgr" "$src" "$bin" "$uninstall"
    done
}

# --- Subcommand: install (flag-driven; the only positionals are package names) ---
cmd_install() {
    local mgr="" bin="" uninstall="" mode="" dry=""
    local pos=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --brew|--cargo|--pip|--apt) mgr="${1#--}"; shift ;;
            --curl)              mgr="curl"; shift ;;
            --list|--ls)         mode="list"; shift ;;
            --outdated|--check)  mode="outdated"; shift ;;
            --discover|--import) mode="discover"; shift ;;
            --menu|--manage)     mode="menu"; shift ;;
            --dry-run|-n)        dry=1; shift ;;
            --bin)               bin="${2:-}"; shift 2 ;;
            --uninstall)         uninstall="${2:-}"; shift 2 ;;
            -h|--help)           install_usage; return 0 ;;
            --)                  shift; while [[ $# -gt 0 ]]; do pos+=("$1"); shift; done ;;
            -*)                  echo "Error: unknown flag '$1'." >&2; install_usage; return 1 ;;
            *)                   pos+=("$1"); shift ;;
        esac
    done

    # Management modes take no package argument.
    if [[ -n "$mode" ]]; then
        if [[ ${#pos[@]} -gt 0 ]]; then
            echo "Error: '--$mode' takes no package argument (got: ${pos[*]})." >&2
            install_usage; return 1
        fi
        case "$mode" in
            list)     install_list ;;
            outdated) install_outdated ;;
            discover) install_discover "$mgr" "$dry" ;;   # optional manager flag scopes it
            menu)     install_menu ;;
        esac
        return $?
    fi

    # curl-pipe-bash install.
    if [[ "$mgr" == curl ]]; then
        local url="${pos[0]:-}" name="${pos[1]:-}"
        if [[ -z "$url" || -z "$name" ]]; then
            echo "Usage: ${prog} install --curl <URL> <NAME> [--bin PATH] [--uninstall CMD]" >&2
            return 1
        fi
        echo "Installing '$name' via: curl -fsSL $url | bash"
        if curl -fsSL "$url" | bash; then
            installs_add "$name" curl "n/a" "$url" "$bin" "$uninstall"
            echo "Installed $name (curl). Tracked; 'update' re-runs the script."
        else
            echo "Error: curl-pipe-bash install failed for '$name'." >&2
            return 1
        fi
        return 0
    fi

    local pkg="${pos[0]:-}"
    if [[ -z "$pkg" ]]; then
        # Bare 'gas install' -> management menu; a lone manager flag is a mistake.
        if [[ -n "$mgr" ]]; then
            echo "Error: --$mgr needs a package name, e.g. '${prog} install ripgrep --$mgr'." >&2
            return 1
        fi
        install_menu; return $?
    fi
    if [[ ${#pos[@]} -gt 1 ]]; then
        echo "Error: install one package at a time (got: ${pos[*]})." >&2
        install_usage; return 1
    fi

    if [[ -n "$mgr" ]]; then
        if ! pkg_available "$mgr"; then echo "Error: '$mgr' is not installed." >&2; return 1; fi
        echo "Installing '$pkg' via $mgr ..."
        if pkg_install "$mgr" "$pkg"; then
            installs_add "$pkg" "$mgr" "$(pkg_installed_version "$mgr" "$pkg")" "$pkg" "" ""
            echo "Installed $pkg ($mgr)."
        else
            echo "Error: $mgr failed to install '$pkg'." >&2
            return 1
        fi
        return 0
    fi

    # No manager flag: try the priority list, first available that succeeds wins.
    local m
    for m in brew cargo pip apt; do
        pkg_available "$m" || continue
        echo "Trying $m install '$pkg' ..."
        if pkg_install "$m" "$pkg"; then
            installs_add "$pkg" "$m" "$(pkg_installed_version "$m" "$pkg")" "$pkg" "" ""
            echo "Installed $pkg ($m)."
            return 0
        fi
        echo "  $m couldn't install '$pkg'; trying next source ..."
    done
    echo "Error: no source (brew/cargo/pip/apt) could install '$pkg'." >&2
    return 1
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

# Wait (briefly, best-effort) until a pane is running a non-shell command — i.e. the
# agent has actually started — so send-keys (e.g. the initial prompt) isn't typed into
# a not-yet-ready process. Times out after ~4s.
wait_for_agent_pane() {
    local pane="$1" i cmd
    for i in $(seq 1 20); do
        cmd=$(tmux display-message -p -t "$pane" '#{pane_current_command}' 2>/dev/null || true)
        case "$cmd" in
            ""|sh|-sh|bash|-bash|zsh|-zsh|fish|-fish|dash|login) sleep 0.2 ;;
            *) return 0 ;;
        esac
    done
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

# Open a URL in the default browser (macOS 'open', Linux 'xdg-open'; else print it).
open_url() {
    local u="$1"
    if command -v open &>/dev/null; then open "$u"
    elif command -v xdg-open &>/dev/null; then xdg-open "$u"
    else echo "$u"; fi
}

# Open the PR for BRANCH (checked out at PATH, if given) in the browser. Resolves
# the PR's URL explicitly with `gh pr view --json url` — the same lookup the status
# preview uses — then opens that exact URL, rather than `gh pr view --web` (which can
# mis-resolve branch names that contain '/'). PATH empty => run gh in the cwd repo.
open_pr_for_branch() {
    local br="$1" wt="${2:-}"
    if ! command -v gh &>/dev/null; then
        echo "gh not installed."
        return 0
    fi
    # Prefer the worktree's actually-checked-out branch (matches the preview).
    if [[ -n "$wt" ]] && [[ -d "$wt" ]]; then
        local cur
        cur=$(git -C "$wt" branch --show-current 2>/dev/null || true)
        [[ -n "$cur" ]] && br="$cur"
    fi
    if [[ -z "$br" ]]; then
        echo "No branch to look up a PR for."
        return 0
    fi
    local prurl
    if [[ -n "$wt" ]] && [[ -d "$wt" ]]; then
        prurl=$(cd "$wt" && gh pr view "$br" --json url --jq .url 2>/dev/null || true)
    else
        prurl=$(gh pr view "$br" --json url --jq .url 2>/dev/null || true)
    fi
    if [[ -n "$prurl" ]]; then
        open_url "$prurl"
        echo "Opened PR for '$br': $prurl"
    else
        echo "No PR found for '$br' (create one with: gh pr create)"
    fi
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

# Remove a worktree and drop it from git metadata and the registry.
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
        # Deleting a worktree is a recursive rm of the whole checkout (tens of
        # thousands of files → many seconds). Instead, move it into the OS temp dir
        # (an instant same-volume rename) and let macOS reap it over time. `git
        # worktree prune` then drops the now-missing worktree's admin entry.
        local trash
        trash="${TMPDIR:-/tmp}/gas-removed-$(basename "$p").$$"
        if mv "$p" "$trash" 2>/dev/null; then
            git -C "$main" worktree prune 2>/dev/null || true
        else
            # mv failed (e.g. truly cross-device) — fall back to a synchronous remove.
            git -C "$main" worktree remove "$p" --force 2>/dev/null || true
            git -C "$main" worktree prune 2>/dev/null || true
        fi
    fi
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
    local menu choice
    menu=$(printf '%s\n' \
        "Open / switch to window" \
        "Update from $dev (pull origin $dev)" \
        "Fetch / refresh remote" \
        "Open PR in browser" \
        "Copy path to clipboard" \
        "Remove worktree")
    # Claude-only: resume a specific past session (Enter/open already --continues).
    if default_harness_is_claude; then
        menu="$menu"$'\n'"Resume claude session (picker)"
    fi
    choice=$(printf '%s\n' "$menu" | fzf --no-multi --prompt='action> ' \
        --header="Actions: $(basename "$path")  [$branch]" || true)
    [[ -z "$choice" ]] && return 0
    case "$choice" in
        "Open / switch"*)
            open_or_switch_worktree "$path" "$branch"
            return 2
            ;;
        "Resume claude session"*)
            local self
            self=$(resolve_self)
            "$self" new --open-worktree "$path" -n "$(basename "$path")" --agent claude --claude-resume
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
            open_pr_for_branch "$branch" "$path"
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
        # `sleep 0.5;` debounces the preview: fzf kills the running preview command when
        # you move to another row, so the (network) `status --fetch` only fires once you
        # rest on a row for 0.5s — not on every keystroke while scrolling.
        out=$(printf '%s\n' "$rows" | fzf --no-multi --ansi \
            --delimiter=$'\t' --with-nth=2,3,4 --expect=ctrl-a \
            --header='enter: open/switch   ctrl-a: actions…    (repo | status | branch)' \
            --preview="sleep 0.5; $self status --fetch {1}" \
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
    local main_repo common
    main_repo=$(git rev-parse --show-toplevel 2>/dev/null || true)
    [[ -z "$main_repo" ]] && { echo ""; return 1; }
    # If run from inside a linked worktree, resolve to the owning repo so the new
    # worktree's dir/registry isn't nested under the worktree's long name.
    common=$(git -C "$main_repo" rev-parse --git-common-dir 2>/dev/null || true)
    [[ "$common" == */.git ]] && main_repo=$(cd "$(dirname "$common")" 2>/dev/null && pwd -P || echo "$main_repo")
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

    # Capture local branches once (also used to subtract from the remote set).
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
            # $path is '-' for remote-only branches; the helper falls back to cwd.
            open_pr_for_branch "$branch" "$path"
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
            --preview="sleep 0.5; $self status --branch {1} {2}" \
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

# Base dir for `fork` clones (independent repos, not worktrees); beside the worktree
# base. Override with $AGENT_SESSION_CLONE_BASE.
get_clone_base() {
    echo "${AGENT_SESSION_CLONE_BASE:-$(dirname "$(get_worktree_base "")")/clones}"
}

# --- Subcommand: fork (clone a DIFFERENT repo, then open a gas window like `dev`) ---
# `gas fork [--deep] [--branch BR] REPO [NAME] [PROMPT...]`
# Clones REPO (shallow by default; --deep = full history) into the durable clone base,
# registers it, and opens a 2-pane agent window rooted in the clone — the same window
# experience as `dev`, but on a fresh clone instead of a worktree.
cmd_fork() {
    local deep=false clone_branch="" repo="" name=""
    local fwd=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --deep) deep=true; shift ;;
            --branch) clone_branch="${2:-}"; shift 2 ;;
            --agent) fwd+=(--agent "${2:-}"); shift 2 ;;
            --ticket) fwd+=(--ticket "${2:-}"); shift 2 ;;
            --prompt-file) fwd+=(--prompt-file "${2:-}"); shift 2 ;;
            -d|--detach) fwd+=(-d); shift ;;
            *)
                if [[ -z "$repo" ]]; then repo="$1"
                elif [[ -z "$name" ]]; then name="$1"
                else fwd+=("$1"); fi
                shift ;;
        esac
    done
    if [[ -z "$repo" ]]; then
        echo "Usage: ${prog} fork [--deep] [--branch BR] REPO [NAME] [PROMPT...]" >&2
        return 1
    fi
    if [[ -z "${TMUX:-}" ]]; then
        echo "Error: Not running inside tmux. Run this from within a tmux session." >&2
        return 1
    fi

    # Derive a clone name + a unique destination dir under the clone base.
    local clone_bn slug base dest n
    clone_bn=$(basename "$repo"); clone_bn="${clone_bn%.git}"
    [[ -z "$name" ]] && name="$clone_bn"
    slug=$(printf '%s' "$name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
    [[ -z "$slug" ]] && slug="fork"
    base=$(get_clone_base)/"$clone_bn"
    mkdir -p "$base"
    dest="${base}/${slug}-$(date +%Y%m%d-%H%M%S)-$$"
    n=0
    while [[ -e "$dest" ]]; do n=$((n + 1)); dest="${base}/${slug}-$(date +%Y%m%d-%H%M%S)-$$-$n"; done

    # Clone (shallow by default; --deep = full).
    local clone_args=(clone)
    [[ "$deep" != true ]] && clone_args+=(--depth 1)
    [[ -n "$clone_branch" ]] && clone_args+=(--branch "$clone_branch")
    clone_args+=("$repo" "$dest")
    echo "Cloning $repo -> $dest ($([[ "$deep" == true ]] && echo full || echo shallow)) ..."
    if ! git "${clone_args[@]}"; then
        echo "Error: git clone failed for '$repo'." >&2
        rm -rf "$dest" 2>/dev/null || true
        return 1
    fi

    # Register so it appears in pick/list and can be cleaned up. It's a standalone
    # clone, so repo == its own path; source_dir records where it was cloned from.
    local br
    br=$(git -C "$dest" branch --show-current 2>/dev/null || true)
    registry_add "$dest" "$br" "$dest" "$br" "$repo"

    # Open the agent window rooted in the clone (reuses the create tail: 2 panes,
    # agent, prompt, claude session), forwarding any --agent/--ticket/prompt/etc.
    local self
    self=$(resolve_self)
    "$self" new --open-worktree "$dest" -n "$name" ${fwd[@]+"${fwd[@]}"}
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
    local reg tmp
    reg=$(get_registry_file)
    [[ ! -f "$reg" ]] && return 0
    # Temp beside the target (same filesystem => atomic mv; no mktemp/TMPDIR dependency,
    # which can fail and, under set -e, derail callers like cleanup).
    tmp="${reg}.tmp.$$"
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

# --- Subcommand: list (alias for system: registry-based worktree listing) ---
cmd_list() {
    # `list` is a friendly alias for `system`: the registry is the source of truth
    # for worktrees (with attached/orphan/stale status).
    cmd_system "$@"
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
        registry_remove "$remove_path"
        echo "Removed worktree: $remove_path"
        return 0
    fi

    if [[ "$purge_stale" == true ]]; then
        local reg
        reg=$(get_registry_file)
        [[ ! -f "$reg" ]] && return 0
        local tmp
        tmp="${reg}.tmp.$$"
        : > "$tmp"
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
    local win wt
    win=$(tmux display-message -p '#{window_index}')
    wt=$(tmux show-window-option -v @agent-worktree 2>/dev/null || true)
    if [[ -z "$wt" ]] || [[ ! -d "$wt" ]]; then
        echo "Current window has no associated worktree (or path missing). Closing window only." >&2
        tmux kill-window -t ":$win"
        return 0
    fi
    # remove_worktree derives the owning repo and runs every git op with `git -C
    # <main-repo>`, so it never depends on (or gets wedged by) the current directory —
    # which is inside the worktree being deleted. Then close this window.
    echo "Removing worktree (moved to temp; macOS reclaims it): $wt"
    remove_worktree "$wt"
    tmux kill-window -t ":$win"
}

# --- Subcommand: doctor (reconcile on-disk state with git; tmux-independent) ---
cmd_doctor() {
    local apply=false interactive=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --fix) apply=true; shift ;;
            -i|--interactive) interactive=true; shift ;;
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

    # 2) Registry entries whose worktree dir is gone.
    #    --fix removes all; -i/--interactive prompts per entry; default just reports.
    local missing=0 removed=0
    if [[ -f "$reg" ]]; then
        local lines=() line p
        while IFS= read -r line; do lines+=("$line"); done < "$reg"
        # Guard the expansion: "${lines[@]}" on an empty array is an unbound-variable
        # error under `set -u` in bash 3.2 (empty registry file).
        for line in ${lines[@]+"${lines[@]}"}; do
            [[ -z "$line" ]] && continue
            p="${line%%|*}"
            if [[ ! -d "$p" ]]; then
                missing=$((missing + 1))
                if [[ "$interactive" == true ]]; then
                    if confirm "MISSING registry entry: $p — remove?"; then
                        registry_remove "$p"; echo "  removed."; removed=$((removed + 1))
                    else
                        echo "  kept."
                    fi
                elif [[ "$apply" == true ]]; then
                    registry_remove "$p"
                    echo "  removed missing: $p"
                    removed=$((removed + 1))
                else
                    echo "  MISSING (use --fix / -i to remove): $p"
                fi
            fi
        done
    fi

    # 3) agent-* worktrees git knows about but the registry doesn't -> re-track.
    local untracked=0 readded=0 wt bn br
    while IFS= read -r r; do
        [[ -z "$r" ]] && continue
        while IFS= read -r wt; do
            [[ -z "$wt" ]] && continue
            [[ ! -d "$wt" ]] && continue
            bn=$(basename "$wt")
            [[ "$bn" != agent-* ]] && continue
            if ! printf '%s' "$registered_canon" | grep -Fxq "$(canon_path "$wt")"; then
                untracked=$((untracked + 1))
                br=$(git -C "$wt" branch --show-current 2>/dev/null || true)
                if [[ "$interactive" == true ]]; then
                    if confirm "UNTRACKED worktree: $wt (branch ${br:-?}) — re-track?"; then
                        registry_add "$wt" "$br" "$r" "" "$r"; echo "  re-tracked."; readded=$((readded + 1))
                    else
                        echo "  skipped."
                    fi
                elif [[ "$apply" == true ]]; then
                    registry_add "$wt" "$br" "$r" "" "$r"
                    echo "  re-tracked: $wt (branch ${br:-?})"
                    readded=$((readded + 1))
                else
                    echo "  UNTRACKED (use --fix / -i to re-track): $wt (branch ${br:-?})"
                fi
            fi
        done < <(git -C "$r" worktree list --porcelain 2>/dev/null | awk '/^worktree /{print $2}')
    done <<< "$repos"

    if [[ "$interactive" == true ]]; then
        echo "Doctor (interactive): removed ${removed}/${missing} missing, re-tracked ${readded}/${untracked} untracked."
    elif [[ "$apply" == true ]]; then
        echo "Doctor: ${removed} missing removed, ${readded} re-tracked."
    else
        echo "Doctor (read-only): ${missing} missing, ${untracked} untracked. Pass --fix (all) or -i (choose per item)."
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
        install)
            subcommand=install
            shift
            break
            ;;
        note)
            subcommand=note
            shift
            break
            ;;
        jira)
            subcommand=jira
            shift
            break
            ;;
        dev)
            subcommand=dev
            shift
            break
            ;;
        fork)
            subcommand=fork
            shift
            break
            ;;
        status)
            subcommand=status
            shift
            break
            ;;
        sessions)
            subcommand=sessions
            shift
            break
            ;;
        edit)
            subcommand=edit
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
if [[ "$subcommand" == jira ]]; then
    cmd_jira "$@"
    exit 0
fi
if [[ "$subcommand" == install ]]; then
    cmd_install "$@"
    exit 0
fi
if [[ "$subcommand" == note ]]; then
    cmd_note "$@"
    exit 0
fi
if [[ "$subcommand" == config ]]; then
    cmd_config "$@"
    exit 0
fi
if [[ "$subcommand" == fork ]]; then
    cmd_fork "$@"
    exit 0
fi
if [[ "$subcommand" == dev ]]; then
    cmd_dev "$@"
    exit 0
fi
if [[ "$subcommand" == edit ]]; then
    cmd_edit "$@"
    exit 0
fi
if [[ "$subcommand" == sessions ]]; then
    cmd_sessions "$@"
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
        --branch-name)
            ((i++)) || true
            branch_name="${remaining[$i]:-}"
            ((i++)) || true
            ;;
        --claude-resume)
            claude_resume=true
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
# Record the resolved command so status/messages reflect exactly what ran.
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
    # If source_repo is itself a linked worktree (e.g. running `gas dev` from inside
    # another gas worktree), --show-toplevel returns the worktree dir, whose basename
    # is a long `agent-…` name. Resolve to the OWNING repo via --git-common-dir so the
    # new branch/dir aren't built from (and compounded onto) that worktree's name.
    src_common=$(git -C "$source_repo" rev-parse --git-common-dir 2>/dev/null || true)
    if [[ "$src_common" == */.git ]]; then
        source_repo=$(cd "$(dirname "$src_common")" 2>/dev/null && pwd -P) || source_repo="$source_repo"
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
    if [[ -n "$branch_name" ]]; then
        # Explicit branch name (may contain '/'), used verbatim as the git branch;
        # callers are responsible for uniqueness. Derive a filesystem-safe dir leaf.
        unique_branch="$branch_name"
        wt_leaf=$(printf '%s' "$branch_name" | tr '[:upper:]' '[:lower:]' | sed -E 's/[^a-z0-9]+/-/g; s/^-+//; s/-+$//')
        worktree_path="${base_dir}/${wt_leaf}"
        n=0
        while [[ -e "$worktree_path" ]]; do
            n=$((n + 1)); worktree_path="${base_dir}/${wt_leaf}-$n"
        done
    else
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
    fi

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

# Create new window (tmux switches to it); ensure unique name. Start it in the
# worktree/dir via -c so BOTH panes inherit it (no racy `cd` send-keys, and works
# regardless of the user's base-index / pane-base-index settings).
if [[ -n "$window_name" ]]; then
    actual_window_name="$window_name"
elif [[ -n "$window_path" ]]; then
    actual_window_name=$(basename "$window_path")
else
    actual_window_name="agent-$(date +%Y%m%d-%H%M%S)"
fi

# Resolve the agent launch command up front. For claude, tie into session
# persistence: a reopened worktree resumes (--continue), a fresh one starts named.
launch_cmd=$(claude_launch_command "$agent_cmd" "$session_cwd" "$actual_window_name")
# Run the agent AS the pane's command (via the shell), dropping back to a login
# shell in the worktree when it exits. Passing it as argv — rather than typing it
# with send-keys — avoids the shell-startup race that dropped the first character(s)
# of the command (e.g. "laude --resume").
win_cmd="$launch_cmd; exec \"\${SHELL:-/bin/sh}\""

if [[ -n "$session_cwd" ]]; then
    tmux new-window -c "$session_cwd" -n "$actual_window_name" "$win_cmd"
else
    tmux new-window -n "$actual_window_name" "$win_cmd"
fi

new_window=$(tmux display-message -p '#{window_index}')
# Target panes by their tmux id (index-agnostic), not .0/.1.
agent_pane=$(tmux display-message -t ":$new_window" -p '#{pane_id}')

# Store worktree path for cleanup
if [[ -n "$worktree_path" ]]; then
    tmux set-window-option -t ":$new_window" @agent-worktree "$worktree_path"
fi
# Store ticket for list/switch
if [[ -n "$ticket" ]]; then
    tmux set-window-option -t ":$new_window" @agent-ticket "$ticket"
fi

# Split vertically for the helper shell; the new pane starts in the same worktree.
if [[ -n "$session_cwd" ]]; then
    tmux split-window -t "$agent_pane" -v -c "$session_cwd"
else
    tmux split-window -t "$agent_pane" -v
fi

# Send the initial prompt into the agent pane, once the agent has actually started
# (so its input isn't raced) — the agent runs as the pane command above.
if [[ -n "$prompt" ]]; then
    wait_for_agent_pane "$agent_pane"
    tmux select-pane -t "$agent_pane"
    tmux send-keys -t "$agent_pane" -- "$prompt"
    tmux send-keys -t "$agent_pane" C-Enter
fi

if [[ "$detach" == true ]]; then
    tmux select-window -t ":$current_window"
    echo "Agent window created in background. To switch to it later:"
    echo "  tmux select-window -t :$new_window"
    echo "Or run: agent-session switch"
else
    echo "Created new window with 2 panes ($agent in top pane)."
fi
