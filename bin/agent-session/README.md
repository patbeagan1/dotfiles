# agent-session

## Description

Creates a new tmux window with 2 vertical panes for agent or multi-pane workflows. Supports worktrees in `/tmp`, agent selection (cursor vs claude), switching windows via fzf (by ticket or title), and pruning/cleanup of worktrees. Worktrees created with `--worktree` are recorded in a **registry** so you can list them, prune by PR status, or force-remove. **Snapshot/restore**: every time a window is added or removed, the set of agent-session windows is written to a snapshot file so you can run `agent-session restore` (inside tmux) after a crash to recreate them. Assumes you are already in a tmux session.

## Usage

Run from inside a tmux session:

```bash
agent-session
agent-session --help
```

### Create session (default)

- **NAME** (default): First positional argument is used as the window name so you can switch to it easily; use `-n`/`--name` to set name explicitly, or `-p`/`--path` to use a path.
- **PROMPT**: Remaining arguments are sent as the first input to the agent. Use `--prompt-file PATH` to read the prompt from a file instead.

```bash
agent-session my-feature "Implement login"
agent-session -n ticket-123 --dir ~/repo --branch develop --ticket 123
agent-session --worktree --branch develop
agent-session --worktree --agent claude --prompt-file ./task.txt
agent-session -d   # create in background, print switch command
```

### Subcommands

- **switch** – Use fzf to search tmux windows by ticket or title and switch to the selected one.
- **list** (or **status**) – List agent-session windows from the snapshot with **attached** (tmux window exists) or **orphan** (in snapshot but no matching window) status. Use this to see what you have running at a glance.
- **system** – List worktrees created by agent-session (locations, branches, and **attached** vs **orphan**). Registry path: `$HOME/.config/agent-session/worktrees` (override with `AGENT_SESSION_REGISTRY`). Use `--purge` to remove stale registry entries. Use `system remove PATH` to force-remove a worktree and unregister it.
- **prune** – List worktrees and PR status (merged/closed = safe to remove), with attached/orphan. Use `--registered-only` to only consider worktrees in the registry. Use `--force-remove` to remove safe worktrees (skips attached windows; run cleanup in that window first). Pass a `PATH` to force-remove that worktree. Use `--find-by-title TITLE` to find a commit on develop by message.
- **cleanup** – Remove the worktree for the current window (if it was created with `--worktree`) and close the window (similar to threeflow finish).
- **snapshot** – Show the current snapshot (list of agent-session windows that would be restored). Updated automatically whenever a window is added or removed.
- **restore** – Recreate all agent-session windows from the last snapshot and re-send the initial prompt to each agent so you can resume tasks after a crash.
- **create-batch FILE** – Create one window per line from FILE. Line format: `name|prompt|ticket` (prompt and ticket optional; do not use `|` inside prompt). Options `-d`, `--worktree`, `--branch`, `--agent` apply to all windows.

```bash
agent-session switch
agent-session list
agent-session create-batch tasks.txt -d --worktree --branch develop
agent-session system
agent-session system --purge
agent-session system remove /tmp/agent-incubator-20250101-120000
agent-session prune
agent-session prune --registered-only
agent-session prune --force-remove
agent-session prune /tmp/agent-incubator-20250101-120000
agent-session prune --find-by-title "Add login"
agent-session cleanup
agent-session snapshot
agent-session restore
```

Snapshot file: `$HOME/.config/agent-session/snapshot` (override with `AGENT_SESSION_SNAPSHOT`).

## Options (create session)

| Option | Description |
|--------|-------------|
| `-h`, `--help` | Show help and exit |
| `-d`, `--detach` | Create window in background and print command to switch later |
| `-n`, `--name NAME` | Set tmux window name (default: first positional is name) |
| `-p`, `--path PATH` | Set path for window name (alternative to `-n`) |
| `--dir DIR` | Starting directory for panes (enables aliases; no need to cd) |
| `--branch BRANCH` | Branch to use (with `--worktree`: base branch for new worktree) |
| `--worktree` | Create a new worktree in `/tmp` with a unique branch; use as cwd for panes |
| `--agent AGENT` | Agent to start: `cursor` (default) or `claude` |
| `--ticket ID` | Ticket or issue ID/URL to associate with this window (for list, switch, prune) |
| `--prompt-file PATH` | Read initial prompt from file instead of positional args |
| `-w`, `--worktree-base DIR` | Base directory for worktrees (default: `/tmp`) |

## Multi-window workflow

To run several agent tasks in parallel (multi-threaded workload):

1. **Naming** – Use a consistent window name so you can find it with `agent-session switch`. For tickets, use the ticket id as name or pass `--ticket` (e.g. `agent-session ticket-123 "Fix login" --ticket 123`).
2. **Create in background** – Use `-d`/`--detach` to create a window without switching to it, then create more; print the switch command for later.
3. **Switch** – Use `agent-session switch` (fzf) or `agent-session list` to see all agent-session windows and their **attached** vs **orphan** status.
4. **Cap concurrency** – Running 3–5 agent windows at a time is usually enough; more can lead to context thrashing. Use `agent-session cleanup` in a window when the task is done, and `agent-session prune` to remove merged/closed worktrees.
5. **Restore** – After a crash, run `agent-session restore` inside tmux. It recreates each window and re-sends the stored initial prompt so you can resume each task.
6. **Batch create** – Put one line per task in a file (`name|prompt|ticket`), then run `agent-session create-batch FILE -d --worktree` to create all windows in the background.

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
- For **switch**: fzf
- For **prune** (PR status): gh CLI (optional)
- For **worktree**: git worktree support

## Author

Pat Beagan (MIT License)
