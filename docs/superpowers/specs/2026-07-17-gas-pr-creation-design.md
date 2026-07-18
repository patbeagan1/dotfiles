# Design: `gas pr` — guided PR creation

**Date:** 2026-07-17
**Component:** `bin/src/agent-session/agent-session.sh` (the `gas` tool)
**Status:** Design — awaiting review

## Context & purpose

Finishing a gas worktree today means manually: reviewing the diff, running
build/lint/tests, finding the Jira ticket, filling the PR template, and running
`gh pr create`. That is repetitive and easy to get wrong (missing Jira link,
skipped checks, wrong template). This adds a `gas pr` subcommand that runs the
whole finish-a-branch flow as a guided pipeline, producing a well-formed draft PR.

The tool is used across repos (it has repo selection), so per-repo specifics
(check commands, template) must not be hard-coded to AllTrails — but AllTrails is
the primary target and its conventions must be honored.

## Non-goals

- Merging PRs (CONTRIBUTING mandates squash-merge by a Maintainer after review).
- Uploading screenshots (left as template placeholders for the human).
- Replacing CI. Local checks are a pre-flight, not a substitute for CI gates.

## Command

```
gas pr [OPTIONS]        # run from inside a gas worktree
```

**Flags:**
- `--skip-review` — skip stage 1 (agentic code review).
- `--skip-checks` — skip stage 2 (build/lint/tests).
- `--ticket KEY` — use KEY instead of picking / deriving from the branch.
- `--base BRANCH` — PR base (default: repo `origin/HEAD`, i.e. `develop`).
- `--ready` — create a normal (non-draft) PR; default is draft.
- `--no-edit` — skip the nvim edit step (use the generated body verbatim).
- `-y`, `--yes` — auto-continue past advisory confirmations (review findings).
- `--reconfigure-checks` — re-prompt for and overwrite this repo's stored check commands.
- `--dry-run` (or `GAS_PR_DRY_RUN=1`) — run the pipeline but print the `gh pr create`
  command instead of pushing/creating; no branch push, no PR. For safe testing.

Registered via the two-part dispatch: a `pr)` case in the parse loop and an
`if [[ "$subcommand" == pr ]]; then cmd_pr "$@"; exit 0; fi` guard, plus usage text
and a `script.meta.yaml` roadmap entry.

## Pipeline

`cmd_pr` orchestrates six stages, each a small helper with one responsibility. It
first validates preconditions: inside a git repo/worktree, a diff exists vs base,
and required tools are present per stage.

### Stage 1 — Agentic code review *(advisory; `--skip-review`)*
`pr_review`: run the existing **`/code-review` skill headless** against the diff
from base:
```
claude -p "/code-review" \
  --allowedTools Read Grep Glob "Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)"
```
Read-only scoped allowlist (no `--dangerously-skip-permissions`). Print the review
output, then `confirm "Proceed despite review findings?"` (auto-yes with `-y`). If
`claude` is missing or the skill invocation fails, fall back to a built-in review
prompt with the same allowlist; if that also fails, warn and continue (advisory).

### Stage 2 — Build / lint / tests *(gating; `--skip-checks`)*
`pr_checks`: **per-repo remembered commands**, prompted once and persisted.
- Look up stored commands for this repo via the existing config mechanism
  (`config_get`/`config_set`), keyed by repo (e.g. `pr.checks.build.<repo>`,
  `pr.checks.test.<repo>`, `pr.checks.lint.<repo>`; repo = basename of the owning
  repo toplevel via `git rev-parse --git-common-dir`).
- If unset (or `--reconfigure-checks`), interactively prompt for each command
  (`prompt_line`), showing sensible AllTrails defaults as the suggestion:
  - build: `./gradlew :app:assembleAlphaDebug`
  - test:  `./gradlew testAlphaDebugUnitTest`
  - lint:  `./gradlew detekt && ./gradlew ktlintFormat`
  (a blank answer for a command means "skip that check for this repo"). Persist.
- **gas runs the commands directly** in the worktree, streaming output, gating on
  exit status. First non-zero → print which check failed and abort (exit non-zero).
  This is deterministic and needs no agent permissions.

> Note: this supersedes the earlier idea of an agentic detect-and-run session —
> per updated guidance, gas asks the user for the commands and remembers them.

### Stage 3 — Ticket selection
`pr_ticket`: resolve the Jira ticket for the PR.
- If `--ticket KEY` given, use it.
- Else if the current branch encodes a key (`<prefix>/<KEY>/<slug>` or
  `<KEY>-...`), default to that (confirm).
- Else reuse `jira_fetch_sprint_json` + `jira_pick_ticket` (fzf) to pick from your
  open-sprint assigned issues. Capture KEY + summary (via the existing
  `jq … select(.key==$k)` idiom / `jira_ticket_details`).
- Ticket is required (release automation needs the Jira link); abort if none.

### Stage 4 — Branch rename to convention
`pr_rename_branch`: gas worktree branches are auto-named `agent-<repo>-<slug>-<ts>`.
Rename to `{initials}/{TICKET}/{slug}`:
- initials: from `git config user.name` (fallback `user.email` local-part), lowercased.
- slug: from the generated title (or ticket summary), git-safe (reuse
  `jira_branch_slug`).
- `git branch -m <new>`; idempotent — if the branch already matches
  `*/{TICKET}/*` leave it. Skipped cleanly if the remote branch already exists.

### Stage 5 — Generate title + body from template + data
`pr_generate`:
- Read the repo PR template (`.github/pull_request_template.md`, then
  `.github/PULL_REQUEST_TEMPLATE.md`, then a minimal built-in fallback).
- A headless `claude -p` (read-only allowlist: Read/Grep/Glob + `Bash(git diff/log/show:*)`)
  produces the filled body + a title, given: the diff vs base, the ticket KEY +
  summary, and the template. It must:
  - fill the JIRA line with `https://<subdomain>.atlassian.net/browse/<KEY>`
    (subdomain via `get_jira_subdomain`), preserving the verbatim release-automation
    separator block;
  - write the **Technical Description** from the diff;
  - add the required **AI-usage disclosure** (Logic Summary, Prompt Disclosure,
    Safety Check) per CONTRIBUTING; include the plan-mode plan if one is discoverable;
  - leave Screenshots / A11y checklist placeholders for the human;
  - emit the title on the first line (ADR 0007: imperative, ≤ ~50 chars,
    references the ticket) and the body after a sentinel.
- gas splits title/body into temp files (`${TMPDIR:-/tmp}/gas-pr-<KEY>.$$`).

### Stage 6 — Edit + publish
`pr_publish`:
- Unless `--no-edit`, open the body temp file in `$(resolve_editor)` (nvim)
  `< /dev/tty > /dev/tty 2>&1` for final edits.
- If a PR already exists for the branch (`gh pr view <branch> --json url,state`),
  offer to update its body (`gh pr edit --body-file`) instead of creating.
- Otherwise push the branch (`git push -u origin <branch>`) and create:
  ```
  gh pr create --base <base> --head <branch> \
    --title "<title>" --body-file <body> [--draft]
  ```
  Draft by default; `--ready` drops `--draft`. Print the PR URL (open via
  `open_url` on confirm).

## Reuse map (existing code)

| Need | Reuse |
|------|-------|
| Ticket picker | `jira_pick_ticket`, `jira_fetch_sprint_json`, `jira_ticket_details`, `get_jira_subdomain` |
| Branch slug | `jira_branch_slug` |
| Editor | `resolve_editor` |
| Prompts / tty | `confirm`, `prompt_line`, `have_tty`, `pause_for_key` |
| Config persistence | `config_get` / `config_set` |
| gh PR guard/pattern | `cmd_status` `gh pr view --json` block; `open_pr_for_branch` |
| Base branch | `git rev-parse --abbrev-ref origin/HEAD \| sed 's|^origin/||'`; `worktree_base_branch` |
| Canonical repo | `git rev-parse --git-common-dir` (linked-worktree caveat) |
| Re-invoke self | `resolve_self` |
| Open URL | `open_url` |

## Error handling

- Each stage guards its dependency (`claude`, `gh`, `acli`, `fzf`, an editor) and
  fails with an actionable message.
- Gating stage (checks) aborts the pipeline on first failure with the failing
  command and its output.
- Advisory stages (review) never block; on tool failure they warn and continue.
- Re-runnable: rename and PR-create are idempotent (detect existing conventional
  branch / existing PR and update instead of duplicating).
- No tty (e.g. run non-interactively) → fzf/nvim/confirm stages degrade: require
  `--ticket` and `--no-edit`, auto-confirm advisories.

## Testing / verification

Bash script with no test harness; verify by exercising real invocations plus
isolated function tests (extract functions + stub externals, run under `bash`,
as done for the repo-selection feature):
- Unit-ish: `pr_ticket` branch-key derivation; `pr_rename_branch` idempotency;
  config get/set round-trip for check commands; template discovery + fallback;
  title/body split parsing of the generation output (stub `claude`).
- Dry-run safety: a `GAS_PR_DRY_RUN=1` env (or `--dry-run`) that prints the
  `gh pr create` command and skips push/create, for end-to-end testing without
  opening a real PR.
- End-to-end (manual, in a throwaway branch): run `gas pr --skip-checks
  --skip-review --no-edit --dry-run` in a worktree and confirm the assembled
  title/body/base/draft flags and branch rename are correct.
- `bash -n` clean; test under macOS bash 3.2.

## Open decision to confirm at review

Stage 2 now uses **prompt-once-and-remember** check commands (run by gas), which
supersedes the initial "one-shot claude session detects and runs" idea. If you
still want an agentic detect step, it can layer in as the default *suggestion*
during the first-time prompt (agent proposes commands, you confirm/edit).
