# gas (agent-session)

> Formerly `agent-session` — renamed to **`gas`** because it's quicker to type. The
> command is `gas`; on-disk state (registry, worktree base, env vars, tmux
> options) still lives under `agent-session`/`AGENT_SESSION_*` for backward compatibility,
> so existing worktrees keep working.

## Description

Creates a new tmux window with 2 vertical panes for agent or multi-pane workflows. Supports durable worktrees (under `~/.local/state`, not `/tmp`), agent selection (cursor vs claude), switching windows/worktrees/branches via fzf, and pruning/cleanup of worktrees. Worktrees created with `--worktree` are recorded in a **registry** — the single source of truth — so you can list them, jump to or reopen them with `gas pick`/`gas branches`, prune by PR status, or force-remove. **Doctor**: `gas doctor` reconciles the on-disk registry with git (tmux-independent) so a crash never leaves the state inconsistent. Assumes you are already in a tmux session.

### Resilience notes

- **Worktrees are durable.** New worktrees live under `${XDG_STATE_HOME:-$HOME/.local/state}/agent-session/worktrees/<repo>/<branch>` (override with `$AGENT_SESSION_WORKTREE_BASE` or `-w`). They are **not** placed in `/tmp`, which macOS clears — that used to delete worktrees out from under git and leave branches "checked out" by ghost worktrees.
- **Creating a worktree can't get blocked.** Each `--worktree` run does `git worktree prune`, fetches the base, and creates a *fresh, uniquely-named* branch off `origin/<branch>` (never checking out a shared branch), so a branch checked out in another worktree never blocks you.
- **Disk is the source of truth.** The registry survives tmux crashes; tmux window options are only a cache. After a crash, run `gas doctor` to reconcile with git, then `gas pick` to reopen the worktrees you want.

## Usage

Run from inside a tmux session:

```bash
gas          # no args -> prints help
gas --help
```

Running `gas` with no arguments, or with an **unrecognized command or parameter**, prints the help text; unrecognized input exits non-zero (it no longer silently creates a window). Use the **`new`** subcommand to create one.

### Quick start — `dev` shortcut

The most common case (a fresh worktree off `develop`) has a one-word shortcut:

```bash
gas dev my-feature "Implement login"
```

is exactly equivalent to:

```bash
gas new --worktree --branch develop -n my-feature "Implement login"
```

Any flags after `NAME` are forwarded to the create flow (e.g. `gas dev my-feature --agent claude`). Override the base branch with `$AGENT_SESSION_DEV_BRANCH` (defaults to `develop`).

### Create session — `new` (alias `create`)

`gas new [OPTIONS] [NAME] [PROMPT]` creates a tmux window (this is the original default behavior, now behind an explicit subcommand).

- **NAME**: First positional argument is used as the window name so you can switch to it easily; use `-n`/`--name` to set name explicitly, or `-p`/`--path` to use a path.
- **PROMPT**: Remaining arguments are sent as the first input to the agent. Use `--prompt-file PATH` to read the prompt from a file instead.

```bash
gas new my-feature "Implement login"
gas new -n ticket-123 --dir ~/repo --branch develop --ticket 123
gas new --worktree --branch develop
gas new --worktree --agent claude --prompt-file ./task.txt
gas new -d   # create in background, print switch command
```

### Subcommands

- **new** (or **create**) – Create a new tmux window (the create-session options above). This is the original default behavior.
- **dev NAME [PROMPT]** – Shortcut for `new --worktree --branch develop -n NAME [PROMPT]` (see Quick start above).
- **fork [--deep] [--branch BR] REPO [NAME] [PROMPT]** – Like `dev`, but instead of creating a worktree of the current repo it **clones a different repo** (`REPO` = a git URL or path) and opens a 2-pane agent window rooted in the clone. Clones are **shallow (`--depth 1`) by default**; pass **`--deep`** for full history, and `--branch BR` to clone a specific branch. `NAME` defaults to the repo name; the clone is registered so it shows in `pick`/`system` and is removed by `cleanup` like any other session. Clones live under `$AGENT_SESSION_CLONE_BASE` (default: `…/agent-session/clones`, beside the worktree base).
- **jira [KEY]** – fzf-pick a Jira ticket from your open sprints (or pass a `KEY` to skip the picker) and open a worktree window for it: a fresh branch `<prefix>/<KEY>/<slug>` (unique — a repeat on the same ticket gets a `-part-N` suffix) off `$AGENT_SESSION_DEV_BRANCH` (default `develop`), tagged `--ticket KEY`, with the agent seeded with the ticket. **`jira list`** prints your open-sprint issues; **`jira create`** creates a ticket interactively and forwards to `acli` (see [Jira](#jira-gas-jira)). Requires [`acli`](https://developer.atlassian.com/cloud/acli/) (Atlassian CLI); set the instance/prefix/project with `gas config jira-subdomain`, `jira-branch-prefix`, and `jira-project`. (Absorbs the old `jirasprintmine`/`jirabranch` zsh functions, which now just call these.)
- **switch** – Use fzf to search tmux windows by ticket or title and switch to the selected one.
- **pick** (or **worktrees**) – fzf picker over gas worktrees (from the registry). The `--preview` pane shows the full state of the highlighted worktree via the `status` command. Press Enter to switch to that worktree's live tmux window, or — if none is attached — open a fresh gas window rooted at it. Press **`ctrl-a`** for an actions menu on the highlighted row (see [Actions menu](#actions-menu-ctrl-a)).
- **branches** (or **pick-branch**) – fzf picker over git branches (local + remote-only). Same rich preview and **`ctrl-a`** actions menu. Enter switches to the branch's existing worktree/window, or creates a worktree for the branch and opens a window. A branch already checked out in the main repo opens a window there instead of creating a divergent branch.
- **status** `[--branch BRANCH] [--fetch] [PATH]` – Print the full state of a worktree/branch: local branch, working-tree status, ahead/behind, whether the branch still exists on the remote (or was deleted/merged), the associated **PR** state via `gh` (number, state, title, url), and the worktree's **Claude session** count + last-active. Used as the picker preview; also handy standalone. `PATH` of `-` or omitted means the current repo. `--fetch` contacts `origin` for **live** remote/merged state (slower; `gas pick` passes it). Degrades gracefully when `gh` is missing/unauthenticated or there is no PR.
- **sessions** `[PATH]` – List the Claude Code sessions recorded for a worktree (default: cwd): session ids + last-active, and how to resume. See [Claude sessions](#claude-sessions). Claude-specific.
- **edit** – fzf-pick one of this project's **skills / rules / subagents** and open it in your editor (`$VISUAL`/`$EDITOR`, else `nvim`→`vim`→`vi`→`nano`), with a content preview. Which files are shown follows the harness: **Claude** → `.claude/skills/<name>/SKILL.md`, `.claude/agents/*.md`, and `CLAUDE.md`/`CLAUDE.local.md` (project **and** `~/.claude/…` global); **Cursor** → `.cursor/rules/*.mdc` and `.cursorrules` (Cursor has no file-based skills or subagents — those are Claude-only); any other harness shows both. Project files are resolved from the git root, so it works from any subdirectory.
- **config** `[harness-command [VALUE]]` – Show or set persistent per-machine config (see [Harness command](#harness-command) below). `config` lists the file; `config harness-command` prints the current harness command; `config harness-command CMD` sets it.
- **install** – Install and track global CLI tools across package managers (see [Installing tools](#installing-tools)). `install [brew|cargo|pip|apt] PKG` (or `--brew` etc.) uses that manager; `install PKG` (no manager) tries **brew → cargo → pip → apt** and keeps the first that succeeds; `install curl URL NAME [--bin PATH] [--uninstall CMD]` runs `curl -fsSL URL | bash`. `install list` lists tracked tools, `install outdated` checks for newer versions, and bare **`install`** opens an fzf menu to **update / check / remove** each tool (forwarding to the right manager).
- **list** – Alias for **system**: the registry-based worktree listing (locations, branches, and **attached**/**orphan**/**stale** status).
- **system** – List worktrees created by gas (locations, branches, and **attached** vs **orphan**). Registry path: `$HOME/.config/agent-session/worktrees` (override with `AGENT_SESSION_REGISTRY`). Use `--purge` to remove stale registry entries. Use `system remove PATH` to force-remove a worktree and unregister it.
- **prune** – List worktrees and PR status (merged/closed = safe to remove), with attached/orphan. Use `--registered-only` to only consider worktrees in the registry. Use `--force-remove` to remove safe worktrees (skips attached windows; run cleanup in that window first). Pass a `PATH` to force-remove that worktree. Use `--find-by-title TITLE` to find a commit on develop by message.
- **doctor** (or **reconcile**) – Reconcile on-disk state with git, independent of tmux. Prunes stale git worktree metadata in every known repo, reports registry entries whose worktree dir is gone, and reports `agent-*` worktrees git knows about but the registry doesn't. Read-only by default; pass `--fix` to remove the missing entries and re-track the untracked ones, or **`-i`/`--interactive`** to decide each one with a y/N prompt. Run this after a tmux/laptop crash, then use `gas pick` to reopen worktrees.
- **cleanup** – Remove the worktree for the current window (if it was created with `--worktree`) and close the window (similar to threeflow finish).
- **create-batch FILE** – Create one window per line from FILE. Line format: `name|prompt|ticket` (prompt and ticket optional; do not use `|` inside prompt). Options `-d`, `--worktree`, `--branch`, `--agent` apply to all windows.

```bash
gas dev my-feature "Implement login"
gas fork https://github.com/org/repo.git experiment "explore the API"
gas fork --deep git@github.com:org/repo.git
gas jira
gas jira list
gas jira create
gas jira PROJ-123
gas switch
gas pick
gas branches
gas status ~/.local/state/agent-session/worktrees/repo/agent-repo-20250101-120000-1234
gas status --branch my-feature
gas sessions
gas edit                # fzf-pick a skill/rule/subagent, open it in $EDITOR
gas install ripgrep                 # auto: brew -> cargo -> pip -> apt
gas install bat --cargo             # force a manager (flag)
gas install --curl https://sh.rustup.rs rustup --bin ~/.cargo/bin/rustup
gas install                         # fzf menu: update / check / remove tracked tools
gas install --outdated              # which tracked tools have updates
gas config harness-command claude
gas list
gas create-batch tasks.txt -d --worktree --branch develop
gas system
gas system --purge
gas system remove ~/.local/state/agent-session/worktrees/repo/agent-repo-20250101-120000-1234
gas prune
gas prune --registered-only
gas prune --force-remove
gas prune ~/.local/state/agent-session/worktrees/repo/agent-repo-20250101-120000-1234
gas prune --find-by-title "Add login"
gas doctor
gas doctor --fix
gas doctor -i
gas cleanup
```

## Options (create session)

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help and exit |
| `-d`, `--detach` | Create window in background and print command to switch later |
| `-n`, `--name NAME` | Set tmux window name (default: first positional is name) |
| `-p`, `--path PATH` | Set path for window name (alternative to `-n`) |
| `--dir DIR` | Starting directory for panes (enables aliases; no need to cd) |
| `--from DIR` | Source repo to branch the worktree from (default: `--dir` if it's a git repo, else current repo) |
| `--branch BRANCH` | Branch to use (with `--worktree`: base branch for new worktree) |
| `--worktree` | Create a durable worktree with a fresh unique branch off `origin/<branch>`; use as cwd for panes |
| `--agent AGENT` | Agent/harness to start: `cursor` (→ `cursor-agent`), `claude`, or any literal command. If omitted, uses the per-machine configured **harness command** (see below). |
| `--ticket ID` | Ticket or issue ID/URL to associate with this window (for list, switch, prune) |
| `--prompt-file PATH` | Read initial prompt from file instead of positional args |
| `--open-worktree PATH` | Open a window on an **existing** worktree path (does not create a new one). Used internally by `pick`/`branches`; can be called directly too. |
| `-w`, `--worktree-base DIR` | Base directory for worktrees (default: `${XDG_STATE_HOME:-$HOME/.local/state}/agent-session/worktrees`; env: `$AGENT_SESSION_WORKTREE_BASE`) |

## Switching worktrees & branches

Two fzf-driven pickers make it easy to jump around and see the full state of each option at the same time:

- `gas pick` (alias `worktrees`) lists your gas worktrees.
- `gas branches` (alias `pick-branch`) lists git branches (local + remote-only).

In both, the **preview pane** (right side) runs `gas status` on the highlighted row, showing:

- local branch and working-tree status (clean / N changes),
- ahead/behind vs upstream,
- whether the branch still **exists on the remote** (deleted-on-origin after merge shows up here). `gas pick` fetches `origin` for the highlighted worktree so this is the **live** remote state; `gas branches` uses the last-fetched local refs for speed,
- whether it's **merged** into the default branch,
- the associated **PR** via `gh` (number, state, title, url, merged-at).

The pickers build their *lists* from local git state only (no network), so they open instantly even in repos with thousands of branches. Network work happens lazily, per highlighted row, in the preview: the `gh` PR lookup for both pickers, plus — for `gas pick` — a `git fetch origin <branch>` so its remote/merged columns reflect what is actually on the remote right now.

Press **Enter** to act on the highlighted item:

- If a live tmux window is already attached to that worktree, it just switches to it.
- Otherwise it opens a fresh gas window (2 panes + agent) rooted at that worktree — via `--open-worktree`, so the window is registered and works with `list`, `system`, and `cleanup` exactly like any other gas window.
- For `branches`, choosing a branch with no worktree yet creates one for it first (a branch already checked out in the main repo opens a window there instead of forking a divergent branch).

`gh` is optional — the preview degrades gracefully (prints a note) when it's missing, unauthenticated, or the branch has no PR.

### Actions menu (`ctrl-a`)

Press **`ctrl-a`** on the highlighted row to open an actions menu (the terminal equivalent of a "⋯" context menu) — a second fzf list of predefined actions on that worktree/branch:

- **Open / switch to window** — same as Enter (leaves the picker).
- **Update from `develop`** — `git pull --no-edit origin develop` into the worktree (override the branch with `$AGENT_SESSION_DEV_BRANCH`); reports conflicts and leaves them for you to resolve.
- **Fetch / refresh remote** — `git fetch --prune origin`.
- **Open PR in browser** — resolves the PR URL for the worktree's current branch (`gh pr view <branch> --json url`, the same lookup as the preview) and opens it in the browser.
- **Copy path / branch name** — to the clipboard via `pbcopy` (macOS; prints the value as a fallback).
- **Remove worktree** — `git worktree remove --force` + unregister, after a confirmation. If a tmux window is attached, it offers to kill that window first.

`Open / switch` leaves the picker; every other action runs, shows its output, and drops you **back in the (refreshed) list** so you can keep acting on items — e.g. remove several in a row. In `gas branches`, the worktree-only actions (remove, update-from-develop) appear only once the branch has a worktree. Destructive actions are guarded (they need an explicit `y`).

## Harness command

The **harness command** is the program launched in the agent pane. It differs per machine — `cursor-agent` on some, `claude` on others — so it's a persistent, per-machine setting rather than hardcoded.

Resolution order when you create a session **without** an explicit `--agent`:

1. `$AGENT_SESSION_HARNESS_COMMAND` (env override), else
2. the saved `harness_command` in the config file, else
3. **you're prompted once** for it on the terminal, and the answer is saved.

Set it explicitly at any time (no prompt needed):

```bash
gas config harness-command claude       # or cursor-agent, or any command
gas config harness-command              # show current value
gas config                              # show the whole config file
```

`--agent` still overrides per-invocation: `cursor` → `cursor-agent`, `claude` → `claude`, or any literal command (e.g. `gas new my-feature --agent aider`). Config file: `$HOME/.config/agent-session/config` (override with `$AGENT_SESSION_CONFIG`).

## Jira (`gas jira`)

`gas jira` turns a Jira sprint ticket into an isolated worktree + agent window in one step (it absorbs the old `jirasprintmine`/`jirabranch` zsh functions):

- `gas jira` — fzf-pick one of your open-sprint issues (query: `assignee = currentUser() AND sprint in openSprints() AND statusCategory != Done`). `gas jira KEY` skips the picker.
- It creates a worktree on a fresh branch **`<prefix>/<KEY>/<slug>`** off `$AGENT_SESSION_DEV_BRANCH` (default `develop`), always **unique** — if the ticket already has a branch, the new one gets a `-part-2` (`-part-3`, …) suffix. The window is tagged `--ticket KEY` and the agent is seeded with the ticket summary + description.
- `gas jira list` prints your open-sprint issues (read-only).
- `gas jira create` (alias `new`) **creates** a ticket interactively — it prompts for project (default from config), type (fzf-pick Task/Story/Bug/Epic/Spike or type your own), summary, **component** (fzf-pick from the project's existing components, or type a new one, or skip), description (inline or `e` to open `$EDITOR`), assignee (default `@me`), and labels. Core fields go through `acli jira workitem create`'s flags; the component is applied as a **best-effort follow-up** `acli jira workitem edit` (acli has no component flag), which never fails the creation — if it can't set the component you still get the ticket plus a warning and the payload to retry. It then prints the new key + URL and offers to open a worktree for it right away.

Config (prompted once, persisted; editable via `gas config`):

```bash
gas config jira-subdomain alltrails        # <this>.atlassian.net
gas config jira-branch-prefix pbeagan      # branch prefix; default derived from your gh username
gas config jira-project TEAM               # default project key for `gas jira create`
```

Requires [`acli`](https://developer.atlassian.com/cloud/acli/) (run `acli auth` once). The subdomain also falls back to the legacy `~/.jira_instance_subdomain` file. Env overrides: `$AGENT_SESSION_JIRA_SUBDOMAIN`, `$AGENT_SESSION_JIRA_BRANCH_PREFIX`, `$AGENT_SESSION_JIRA_PROJECT`.

## Claude sessions

When the harness is **Claude Code**, `gas` treats a worktree's conversation as first-class. Claude stores each conversation per project directory (`${CLAUDE_CONFIG_DIR:-$HOME/.claude}/projects/<slug>/`, one JSONL per session), and a gas worktree maps 1:1 to such a directory. `gas` only reads the transcript *files* (count + last-modified — stable); it never parses their contents (that format is internal to Claude Code).

- **Resume on reopen** — opening a worktree from `gas pick`/`branches` (or any reopen) launches `claude --continue`, resuming that worktree's most recent conversation instead of a blank one. A brand-new worktree launches `claude -n <window/branch/ticket>`, so the session is named and shows up in `/resume`.
- **Session info in the picker** — `gas status` (and thus the `pick`/`branches` preview) shows `Claude sessions: N (last active …)` for the worktree.
- **`gas sessions [PATH]`** — lists a worktree's sessions (ids + last-active) and prints the resume commands.
- **Actions menu** — when the default harness is claude, the `pick` `ctrl-a` menu gains **"Resume claude session (picker)"**, which opens Claude's interactive `--resume` picker for that worktree (to pick an older session; plain Enter already `--continue`s the latest).

This is entirely Claude-specific; other harnesses (cursor-agent, aider, …) are launched unchanged. Move storage with `$CLAUDE_CONFIG_DIR` and it's honored here too.

## Installing tools

`gas install` is a thin cross-manager layer for the global CLI tools you install, so you can later see what you have, check for updates, and update/remove them in one place. It **tracks** each install in a registry (`$AGENT_SESSION_INSTALLS`, default `~/.config/agent-session/installs`), one line per tool: `name|manager|version|installed_at|source|bin|uninstall`.

**Installing:**

The **only positional argument is the package name** — the manager, curl mode, and list/outdated modes are all flags, so nothing is ambiguous (`gas install list` installs a package called `list`; `gas install --list` lists tracked tools).

```bash
gas install ripgrep                    # no flag -> try brew, then cargo, then pip, then apt
gas install eza --cargo                # force a manager with a flag
gas install --curl https://sh.rustup.rs rustup --bin ~/.cargo/bin/rustup   # curl | bash
```

Supported managers: **brew, cargo, pip (`pip3 install --user`), apt (`sudo apt-get`), and curl-pipe-bash.** With no manager flag, gas walks the priority list **brew → cargo → pip → apt** (skipping any that aren't installed) and keeps the first that succeeds.

**Managing** (forwards to the owning manager):

```bash
gas install --list       # fast list from the registry (name, manager, version, source)
gas install --outdated   # check latest versions on demand (brew/pip/apt; cargo via crates.io; curl = n/a)
gas install              # fzf menu -> Update / Check latest version / Remove / Copy source
```

| Action | brew | cargo | pip | apt | curl-pipe-bash |
| --- | --- | --- | --- | --- | --- |
| update | `brew upgrade` | `cargo install --force` | `pip3 install --user -U` | `apt-get install --only-upgrade` | re-run `curl \| bash` |
| remove | `brew uninstall` | `cargo uninstall` | `pip3 uninstall -y` | `apt-get remove` | `--uninstall CMD`, else `rm --bin`, else untrack + warn |
| latest | `brew info --json` | crates.io API | `pip index versions` | `apt-cache policy` | n/a |

Because a `curl | bash` install has no owning manager, gas records the URL: **update** re-runs it (most scripts install latest), and **remove** uses the `--uninstall CMD` or `--bin PATH` you gave at install time (otherwise it just untracks and reminds you to delete the binary yourself).

## Multi-window workflow

To run several agent tasks in parallel (multi-threaded workload):

1. **Naming** – Use a consistent window name so you can find it with `gas switch`. For tickets, use the ticket id as name or pass `--ticket` (e.g. `gas new ticket-123 "Fix login" --ticket 123`).
2. **Create in background** – Use `-d`/`--detach` to create a window without switching to it, then create more; print the switch command for later.
3. **Switch** – Use `gas switch` (fzf over windows) or `gas pick` / `gas branches` (fzf over worktrees/branches with a live state + PR preview) to jump around; `gas list`/`gas system` show all worktrees and their **attached**/**orphan**/**stale** status.
4. **Cap concurrency** – Running 3–5 agent windows at a time is usually enough; more can lead to context thrashing. Use `gas cleanup` in a window when the task is done, and `gas prune` to remove merged/closed worktrees.
5. **Recover after a crash** – The registry is the source of truth. Run `gas doctor` to reconcile it with git (prune ghosts, drop missing, re-track strays), then `gas pick` to reopen the worktrees you want — each opens a fresh window via the normal flow. (Note: the original prompt is not automatically replayed.)
6. **Batch create** – Put one line per task in a file (`name|prompt|ticket`), then run `gas create-batch FILE -d --worktree` to create all windows in the background.

## Layout

Adds a new window with 2 panes stacked vertically (agent in top pane):

```
+------------------+
| agent (cursor/   |
| claude)          |
+------------------+
| second pane      |
+------------------+
```

## Requirements

- Bash
- An active tmux session
- For **switch**, **pick**, **branches**, **jira**: fzf
- For **prune**/**status** (PR status): gh CLI (optional; preview degrades gracefully without it)
- For **jira**: `acli` (Atlassian CLI) + jq
- For **worktree**: git worktree support

## Author

Pat Beagan (MIT License)
