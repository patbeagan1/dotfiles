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

**Picking the repo.** By default the worktree branches from the repo you're currently in. To start a session for a *different* project without `cd`-ing there first, add `--repo`:

```bash
gas dev my-feature --repo alltrails_android_2   # by name (from past sessions)
gas dev my-feature --repo                        # fzf-pick from known repos
```

Known repos come from the repos used in your past sessions (the registry). If you run `gas dev`/`gas new --worktree` from a directory that isn't a git repo and don't pass `--repo`/`--from`, the picker opens automatically instead of erroring.

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
- **board** – Opens **the one picker in the agent lens** (see [Fleet orchestration](#fleet-orchestration)): agents *sorted by who needs you*, rows showing status + the **pending question**, preview = live pane + git. Enter opens; **`ctrl-a`** = the unified actions menu; **`ctrl-t`** toggles to the git lens (i.e. `pick`). Non-interactive dashboard variants for status bars/scripts: `--plain`, `--line` (`⚙/⏳/✓`), `--watch [SECS]`, `--conflicts`.
- **next** – **Cycle** to the next agent waiting on you (skips the current window, so tapping it repeatedly walks your blocked agents) and print its question. Ideal as a tmux key-binding.
- **answer** `[--to NAME] [MSG]` – Reply into an agent's pane **without** switching. With no `MSG` it shows the agent's question and **prompts** you for the reply; targets the `next` waiting agent or `--to NAME`.
- **conflicts** – Scan all agents and report **files changed by more than one of them** (vs each worktree's base), so overlapping work surfaces before it collides. Also `board --conflicts`.
- **integrate** `[--repo PATH]` – Preview how the parallel agents' branches will merge: candidate branches + status per repo, **cross-branch conflict preview** via `git merge-tree`, and a suggested landing order. Read-only — never merges.
- **pr** `[--ticket KEY] [--base BRANCH] [--dry-run] [-y|--yes]` – Guided PR creation from the current worktree. See [PR creation](#pr-creation-gas-pr).
- **hooks** `[--install|--uninstall|--status] [--user]` – Install the Claude Code hooks that report each agent's real status to the fleet. See [Fleet orchestration](#fleet-orchestration).
- **pick** (or **worktrees**) – Opens **the one picker in the git lens**: gas worktrees (from the registry) sorted attached→orphan, with a `status` preview (git state + PR). Enter switches to the worktree's live tmux window (or opens one for orphans); **`ctrl-a`** opens the unified actions menu (see [Actions menu](#actions-menu-ctrl-a)); **`ctrl-t`** toggles to the agent lens (i.e. `board`). It's the same picker as `board` — just a different default lens/sort/preview.
- **branches** (or **pick-branch**) – fzf picker over git branches (local + remote-only). Same rich preview and **`ctrl-a`** actions menu. Enter switches to the branch's existing worktree/window, or creates a worktree for the branch and opens a window. A branch already checked out in the main repo opens a window there instead of creating a divergent branch.
- **status** `[--branch BRANCH] [--fetch] [PATH]` – Print the full state of a worktree/branch: local branch, working-tree status, ahead/behind, whether the branch still exists on the remote (or was deleted/merged), the associated **PR** state via `gh` (number, state, title, url), and the worktree's **Claude session** count + last-active. Used as the picker preview; also handy standalone. `PATH` of `-` or omitted means the current repo. `--fetch` contacts `origin` for **live** remote/merged state (slower; `gas pick` passes it). Degrades gracefully when `gh` is missing/unauthenticated or there is no PR.
- **sessions** `[PATH]` – List the Claude Code sessions recorded for a worktree (default: cwd): session ids + last-active, and how to resume. See [Claude sessions](#claude-sessions). Claude-specific.
- **edit** – fzf-pick one of this project's **skills / rules / subagents** and open it in your editor (`$VISUAL`/`$EDITOR`, else `nvim`→`vim`→`vi`→`nano`), with a content preview. Which files are shown follows the harness: **Claude** → `.claude/skills/<name>/SKILL.md`, `.claude/agents/*.md`, and `CLAUDE.md`/`CLAUDE.local.md` (project **and** `~/.claude/…` global); **Cursor** → `.cursor/rules/*.mdc` and `.cursorrules` (Cursor has no file-based skills or subagents — those are Claude-only); any other harness shows both. Project files are resolved from the git root, so it works from any subdirectory.
- **config** `[harness-command [VALUE]]` – Show or set persistent per-machine config (see [Harness command](#harness-command) below). `config` lists the file; `config harness-command` prints the current harness command; `config harness-command CMD` sets it.
- **install** – Install and track global CLI tools across package managers (see [Installing tools](#installing-tools)). The only positional is the package name; everything else is a flag: `install PKG` tries **brew → cargo → pip → apt** and keeps the first that succeeds, `install PKG --brew` (or `--cargo`/`--pip`/`--apt`) forces one, `install --curl URL NAME [--bin PATH] [--uninstall CMD]` runs `curl -fsSL URL | bash`. `install --discover` imports tools you already have, `install --list` lists tracked tools, `install --outdated` checks for newer versions, and bare **`install`** opens an fzf menu to **update / check / remove** each tool (forwarding to the right manager).
- **note** – Manage plain-text note files, interactively **or non-interactively for agents** (see [Notes](#notes)). `note --new TITLE` opens your editor, or writes straight to disk when a body is supplied (`--body TEXT`, `--body -`, or piped stdin) plus `--no-edit`; `note --append NAME` appends stdin/`--body` and **auto-creates** the note (an agent scratchpad). `--edit`/`--cat`/`--path`/`--delete [NAME]` act on a note (fzf-pick when `NAME` is omitted and a terminal is present; `--delete --yes` skips the confirm), `--search TERM` greps all notes (returns `name:line:match`), `--list [--json]` lists them (JSON includes `bytes`/`lines`), and `--project`/`-p` scopes to the current repo. Bare **`note`** opens an fzf menu.
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
gas install --discover              # import what you already have installed
gas install                         # fzf menu: update / check / remove tracked tools
gas install --outdated              # which tracked tools have updates
gas note --new "deploy checklist"   # create a note and open it in $EDITOR
gas note --cat deploy-checklist     # print a note by name
gas note                            # fzf menu: edit / cat / delete notes
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
| `--repo NAME` | Source repo **by name**, matched (case-insensitive, by basename) against repos used in past sessions; also accepts a path. Bare `--repo` (no value) opens an fzf picker of known repos. When you're not in a git repo and pass neither `--repo` nor `--from`, the picker opens automatically. Mutually exclusive with `--from`. |
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

## PR creation (`gas pr`)

`gas pr` turns a finished worktree into a well-formed **draft** GitHub PR through a guided pipeline. Run it from inside the worktree; it is **interactive by default** (it asks at each gate) with a few flags for non-interactive use.

Pipeline:

1. **Agentic code review** *(advisory)* — runs your `/code-review` skill headless (read-only tool allowlist) over the diff vs the base branch, **streaming its progress live** (tool activity + findings as they happen, via `stream-json` rendered with `jq`), then asks whether to proceed.
2. **Build / lint / tests** *(gating)* — runs this repo's commands and aborts on the first failure. The commands are **remembered per repo**: the first time you run `gas pr` in a repo it prompts you for the build, test, and lint commands (with AllTrails gradle defaults as suggestions) and stores them in the gas config; a blank answer skips that check. To change them later, edit/delete the `pr_checks_*_<repo>` keys in `$AGENT_SESSION_CONFIG` (default `~/.config/agent-session/config`).
3. **Ticket** — uses the JIRA key encoded in the branch name if present (confirmed), otherwise fzf-picks from your open-sprint assigned tickets (same picker as `gas jira`).
4. **Branch rename** — renames the auto `agent-*` branch to the convention `{initials}/{TICKET}/{slug}` (idempotent).
5. **Title + description** — reads the repo PR template (`.github/pull_request_template.md`), then a headless `claude` (read-only allowlist) fills it from the diff + ticket: the JIRA link, a Technical Description, and an AI-usage disclosure — leaving screenshots/a11y checkboxes for you.
6. **Edit + publish** — opens the description in your `$EDITOR` (nvim) for final edits, then `git push` + `gh pr create --draft`. If a PR already exists for the branch it offers to update it instead.

Flags (overrides; default flow is interactive):

| Flag | Effect |
|------|--------|
| `--ticket KEY` | Use KEY instead of deriving/picking the ticket |
| `--base BRANCH` | PR base branch (default: repo `origin/HEAD`, e.g. `develop`) |
| `--dry-run` (or `GAS_PR_DRY_RUN=1`) | Print the `gh pr create` command; no push, no PR |
| `-y`, `--yes` | Non-interactive: accept prompts, skip the review confirm and the editor; unconfigured checks are skipped rather than prompted |

Requires `gh` (authenticated) and `claude`; the ticket step also uses `acli`/`fzf`. Each step degrades or aborts with a clear message when its dependency is missing.

## Fleet orchestration

You are the orchestrator; the Claude agents are your subagents, each running as an **independent instance** in its own worktree + tmux window + context window. Claude Code is great at *one* conversation, but nothing aggregates the *many* independent instances you're running at once — that cross-instance view is what the fleet commands add.

The design principle: **don't guess what the harness already knows — bridge it.** Instead of scraping panes to infer whether an agent is working or blocked, gas installs Claude Code **hooks** so each agent reports its *authoritative* status (and the exact question it's blocked on) to a small per-worktree state file. gas then aggregates those across every instance.

### Setup: install the hooks

```bash
gas hooks --install      # writes to this repo's .claude/settings.json (merges + backs up)
gas hooks --install --user   # or globally, in ~/.claude/settings.json
gas hooks --status       # show whether hooks are installed + the fleet state dir
gas hooks --uninstall    # remove them (restores from a .bak)
```

This registers four hooks (requires `jq`, and never clobbers your other settings): `Notification → waiting` (also captures the question), `Stop → idle/done`, and `UserPromptSubmit`/`SessionStart → working`. Each just runs `gas hook-report <status>`, which appends `ts|status|session|message` to `$AGENT_SESSION_FLEET/<cwd-slug>` (default `~/.local/state/agent-session/fleet/`). If the harness isn't Claude, gas falls back to the pane's running command — coarser, but no fabricated detail.

### Conduct the fleet

tmux's own `leader w` already lets you *switch* windows with a live preview. The fleet commands do the thing tmux can't: they know each agent's **semantic state** — who is *waiting on you*, *the exact question they asked*, and whether you've *reviewed* their output — and let you act on it.

```bash
gas board                # INTERACTIVE triage console (fzf), agents sorted by who needs you
gas board --line         # "⚙3 ⏳2 ✓1" — drop into tmux status-right for ambient awareness
gas board --watch 3      # auto-refreshing table (pin it in its own window)
gas board --plain        # a plain table (for scripts / no-tty)

gas next                 # cycle to the next agent waiting on you (skips the current window)
gas answer --to fix-sync "use Postgres"   # reply straight into that agent's pane
gas answer                                # prompt to answer the current 'next' waiting agent
```

`gas board` and `gas pick` are **the same picker** — two default lenses over your worktrees. In the agent lens (`board`), rows are ordered **waiting → done → working**, each showing the pending question, and the preview fuses the agent's **live pane content** with its status + git state. From there:

- **Enter** — jump to that agent's window.
- **`ctrl-a`** — the unified actions menu: **Answer** (type a reply sent into the pane), **Review diff**, **Mark reviewed** (clears it from your attention queue — a state tmux has no concept of), plus the worktree actions (update from dev, fetch, open PR, copy path, remove worktree, kill window, resume-claude).
- **`ctrl-t`** — toggle to the git lens (`pick`): same rows, sorted by worktree state with the git/PR preview — so you can flip from *conducting* an agent to *managing* its worktree without leaving the picker.

This is the throughput win: instead of touring six panes to find who's blocked, you triage from one list — see the question, answer it, mark it reviewed, move on. Bind `gas next` to a tmux key to walk blocked agents one tap at a time, and add the summary to your status bar with `set -g status-right '#(gas board --line)'`.

### Catch collisions early, integrate deliberately

Running many agents on one repo, two of them will eventually edit the same file. These two commands surface that **before** it turns into a merge headache:

```bash
gas conflicts            # files changed by >1 agent (vs each worktree's base)
gas board --conflicts    # the board, with the collision report appended

gas integrate            # per repo: candidate branches + status, cross-branch conflict
                         # preview (git merge-tree), and a suggested landing order
gas integrate --repo ~/src/app   # scope to one repo
```

`gas conflicts` intersects each agent's changed-file set, so you see e.g. `src/sync.kt → fix-sync, refactor` at a glance. `gas integrate` goes further and dry-runs the merges: it reports which branch pairs collide and on which files, then suggests landing the clean branches first and resolving the entangled ones last. Both are **read-only** — they never touch your branches or working trees.

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

**Discovery** (retroactive tracking). The first time you use `gas install`, you probably already have tools installed the old way. `--discover` queries each available manager for its explicitly-installed packages and adds any that aren't tracked yet — so you start with a full list instead of an empty one:

```bash
gas install --discover          # import from every available manager (brew, cargo, pip, apt)
gas install --discover --brew   # scope to one manager
gas install --discover -n       # dry run: show what would be imported, change nothing
```

It only looks at **top-level** installs — `brew leaves`, `cargo install --list`, `pip list --user`, `apt-mark showmanual` — not pulled-in dependencies, and a tool present under two managers is imported once. curl installs can't be discovered (there's no manager to ask).

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

## Notes

`gas note` is a tiny note manager built on the same flag-or-fzf pattern as `install`. Notes are plain markdown files in `$AGENT_SESSION_NOTES` (default `~/.config/agent-session/notes`), so they're easy to grep, sync, or edit by hand.

### Interactive (human) use

```bash
gas note --new "release steps"   # slugified to release-steps.md, seeded with "# release steps", opened in $EDITOR
gas note --edit release-steps    # edit by name (with or without the .md)
gas note --cat release-steps     # print it
gas note --delete release-steps  # delete (asks to confirm)
gas note --list                  # list notes (filename + size + first-line title)
gas note                         # fzf menu -> pick a note, then Edit / Cat / Delete
gas note release-steps           # shorthand: no flag + a name == --edit
```

The name argument is optional for `--edit`/`--cat`/`--path`/`--delete`; leave it off (at a terminal) and gas opens an fzf picker with a content preview. The editor is resolved the same way as `gas edit` — `$VISUAL`, then `$EDITOR`, then `nvim`→`vim`→`vi`→`nano`.

### Non-interactive use (agents)

Everything works without a terminal, which makes notes a durable scratchpad for an agent driving `gas` in a tmux pane:

```bash
# create with a body (no editor); --no-edit is implied once a body is present
echo "1. bump version\n2. tag\n3. push" | gas note --new "release steps"
gas note --new plan --body "investigate flaky test" --no-edit

# append findings across steps — auto-creates the note the first time
grep -c TODO src/*.py | gas note --append findings --quiet
gas note --append findings --body "auth module looks done"

# read cheaply: search returns only matching lines, --path lets you read with your own tool
gas note --search "flaky"        # -> findings:3:the flaky test is in test_auth.py
p=$(gas note --path findings)    # just the path; then read it with offsets/limits
gas note --list --json           # [{"name","path","title","bytes","lines"}, ...]

# delete without a prompt
gas note --delete findings --yes
```

Non-interactive behavior is automatic: `--new`/`--append` read piped stdin (or `--body -`), the editor is skipped whenever a body is supplied or there's no terminal, and if you omit `NAME` where a picker would be needed but there's no tty, gas prints a clear "pass a NAME / use `--search`" error instead of failing on fzf. `--quiet` trims output to just the file path.

### Project-scoped notes

Add `--project` (or `-p`) to scope notes to the current repository instead of the global dir — stored under `$AGENT_SESSION_NOTES/proj/<repo-slug>/`:

```bash
gas note --project --append findings --body "repo-specific note"
gas note -p --list
```

Scoping is resolved via `git rev-parse --git-common-dir`, so a **linked worktree and its main repo share the same project notes** — an agent's findings in one worktree are visible from another worktree of the same repo. `--global` forces the shared dir. Outside a git repo, `--project` errors.

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
