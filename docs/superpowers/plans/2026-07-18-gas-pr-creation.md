# `gas pr` — guided PR creation — Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Add a `gas pr` subcommand that turns a finished gas worktree into a well-formed draft GitHub PR via a guided pipeline: agentic code review → build/lint/tests → ticket pick → branch rename → template-filled title/body → nvim edit → `gh pr create`.

**Architecture:** One new orchestrator `cmd_pr` in `bin/src/agent-session/agent-session.sh` plus focused `pr_*` helper functions, each with one responsibility. Reuses existing Jira picker, editor resolver, tty/confirm helpers, config persistence, and gh guard patterns. Agentic sub-steps shell out to `claude -p` with a **read-only tool allowlist**; the checks step runs **per-repo remembered commands** directly in the shell and gates on exit code.

**Tech Stack:** Bash (target macOS bash 3.2), `git`, `gh` CLI, `claude -p` (headless), `acli` (Jira), `fzf`, `jq`, `nvim`/`$EDITOR`.

## Global Constraints

- Target **bash 3.2** (macOS default). No `tac` (use `tail -r`), no associative arrays, no `${var^^}` — use `tr`. Match existing script idioms.
- Script uses `set -euo pipefail`. Guard every command whose non-zero status is expected (`|| true`), especially the last statement of loops/functions used in `$(...)`.
- **Err toward interactivity, not flags.** Default behavior asks the user (fzf pick, `[Y/n]` confirms). Flags exist only as non-interactive overrides. Flag set is intentionally small: `--ticket KEY`, `--base BRANCH`, `--dry-run`, `-y/--yes` (auto-accept all prompts, for non-interactive use). NO `--skip-review`/`--skip-checks`/`--ready`/`--no-edit`; those choices are interactive prompts.
- **Reuse, don't duplicate:** `jira_pick_ticket`, `jira_fetch_sprint_json`, `jira_ticket_details`, `get_jira_subdomain`, `jira_branch_slug`, `resolve_editor`, `confirm`, `prompt_line`, `have_tty`, `config_get`, `config_set`, `resolve_self`, `open_url`, and the `gh pr view --json` guard from `cmd_status`.
- **PR facts (AllTrails, verbatim):** base branch `develop` (via `git rev-parse --abbrev-ref origin/HEAD`); PR template `.github/pull_request_template.md`; Jira URL form `https://<subdomain>.atlassian.net/browse/<KEY>`; the template's `----------` separator + comment block are "required verbatim for release automation"; branch convention `{initials}/{JIRA-TICKET}/{short-description}`; PRs created **draft** by default; PR title imperative, ≤~50 chars, references ticket (ADR 0007); PR description must include the Jira link and an **AI-usage disclosure** (Logic Summary / Prompt Disclosure / Safety Check).
- All new code lives in `bin/src/agent-session/agent-session.sh`. Docs in that dir's `README.md` and `script.meta.yaml`.
- Insertion points are given by **content anchors** (nearby existing code), not line numbers — the file changes as tasks land.

## Testing approach for this bash tool

There is no test harness. Each logic-bearing function is tested by **extracting it with `sed` into a temp file, stubbing external commands (`git`, `gh`, `claude`, `acli`, `fzf`, `config_get/set`), sourcing under `bash`, and asserting stdout/exit** — the exact pattern already used to validate the repo-selection feature. Reusable test skeleton (referenced by tasks as "the harness"):

```bash
# $TMPDIR-based; F=path to agent-session.sh; extract one function by name:
extract() { sed -n "/^$1() {/,/^}/p" "$F"; }
# Build a lib with stubs + the function(s), then run assertions under bash.
```

Interactive/agentic stages are tested by stubbing `claude`/`gh`/`fzf` to emit canned output and asserting the constructed command / control flow (via `--dry-run` and echo-stubs).

---

### Task 1: Register the `pr` subcommand (scaffold + preconditions)

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (parse loop, dispatch guards, usage heredoc; add `cmd_pr` skeleton near `cmd_integrate`)

**Interfaces:**
- Produces: `cmd_pr "$@"` entry point; parses the small flag set into globals `pr_ticket_arg`, `pr_base`, `pr_dry_run`, `pr_yes`.

- [ ] **Step 1: Write the failing test** — `gas pr` outside any git repo must error; the scaffold must reach a recognizable marker inside a repo. Create `"$TMPDIR/t1.sh"`:

```bash
set -e
F="$HOME/repo/dotfiles/bin/src/agent-session/agent-session.sh"
# Not-in-repo: cmd_pr should print a clear error and exit non-zero.
cd "$TMPDIR"
out=$(bash -c '
  cd "'"$TMPDIR"'"
  # extract cmd_pr + minimal deps and drive it
  '"$(sed -n '/^cmd_pr() {/,/^}/p' "$F")"'
  cmd_pr
' 2>&1) && rc=0 || rc=$?
echo "rc=$rc out=$out"
echo "$out" | grep -qi "not in a git repo\|no changes\|git repository" && echo PASS-ERR || echo FAIL-ERR
```

- [ ] **Step 2: Run it to verify it fails**

Run: `bash "$TMPDIR/t1.sh"`
Expected: FAIL (`cmd_pr` not yet defined → extraction empty → error).

- [ ] **Step 3: Add the parse-loop case.** After the `integrate)` case in the subcommand parse loop, add:

```bash
        pr)
            subcommand=pr
            shift
            break
            ;;
```

- [ ] **Step 4: Add the dispatch guard.** After the `if [[ "$subcommand" == integrate ]]` block, add:

```bash
if [[ "$subcommand" == pr ]]; then
    cmd_pr "$@"
    exit 0
fi
```

- [ ] **Step 5: Add the `cmd_pr` skeleton** near `cmd_integrate`:

```bash
# --- Subcommand: pr (guided PR creation) ---
# Runs from inside a gas worktree. Pipeline: review -> checks -> ticket ->
# rename -> generate -> edit -> publish. Interactive by default; flags override.
cmd_pr() {
    local pr_ticket_arg="" pr_base="" pr_dry_run=false pr_yes=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -h|--help) echo "Usage: ${prog} pr [--ticket KEY] [--base BRANCH] [--dry-run] [-y|--yes]"; return 0 ;;
            --ticket)  shift; pr_ticket_arg="${1:-}"; shift || true ;;
            --base)    shift; pr_base="${1:-}"; shift || true ;;
            --dry-run) pr_dry_run=true; shift ;;
            -y|--yes)  pr_yes=true; shift ;;
            *) echo "Error: unknown option for 'pr': $1" >&2; return 1 ;;
        esac
    done
    [[ "${GAS_PR_DRY_RUN:-}" == 1 ]] && pr_dry_run=true

    # Precondition: inside a git work tree with a resolvable repo.
    if ! git rev-parse --is-inside-work-tree &>/dev/null; then
        echo "Error: 'gas pr' must be run inside a git repository (worktree)." >&2
        return 1
    fi
    local repo base branch
    repo=$(git rev-parse --show-toplevel 2>/dev/null)
    base="${pr_base:-$(git rev-parse --abbrev-ref origin/HEAD 2>/dev/null | sed 's|^origin/||')}"
    [[ -z "$base" ]] && base="${AGENT_SESSION_DEV_BRANCH:-develop}"
    branch=$(git branch --show-current 2>/dev/null)

    # Precondition: there is a diff vs base.
    git fetch origin "$base" 2>/dev/null || true
    if git diff --quiet "origin/${base}...HEAD" 2>/dev/null; then
        echo "Error: no changes vs origin/${base} — nothing to open a PR for." >&2
        return 1
    fi
    echo "Preparing PR: branch '${branch}' → base '${base}' (repo: $(basename "$repo"))"
    # Stages wired in later tasks:
    #   pr_review "$base" "$pr_yes"
    #   pr_checks "$repo" "$pr_yes"
    #   ... etc
}
```

- [ ] **Step 6: Run test to verify it passes**

Run: `bash "$TMPDIR/t1.sh"`
Expected: PASS-ERR (not-in-repo path errors as expected).

- [ ] **Step 7: Add usage text.** In the usage heredoc's subcommand list, add a `pr` line near `integrate`:

```
  pr               Guided PR creation from the current worktree: agentic code review,
                   build/lint/tests, Jira ticket pick, template-filled draft PR (gh).
```

- [ ] **Step 8: `bash -n` and commit**

Run: `bash -n bin/src/agent-session/agent-session.sh && echo OK`
```bash
git add bin/src/agent-session/agent-session.sh
git commit -m "feat(gas): scaffold 'gas pr' subcommand + preconditions"
```

---

### Task 2: Per-repo check-command config (prompt-once, remember)

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (add `pr_checks_get_cmds`, `pr_checks_configure` near the config helpers)

**Interfaces:**
- Consumes: `config_get KEY`, `config_set KEY VALUE` (existing).
- Produces:
  - `pr_repo_key <repo_toplevel>` → echoes a stable slug (basename of `--git-common-dir` owner) used in config keys.
  - `pr_checks_get_cmds <repo>` → prints three lines (build / test / lint), each possibly empty; prompts+persists on first use.
  - `pr_checks_configure <repo>` → force re-prompt + persist.
  - Config keys: `pr.checks.build.<key>`, `pr.checks.test.<key>`, `pr.checks.lint.<key>`.

- [ ] **Step 1: Write the failing test** (the harness). Extract `pr_repo_key`, `pr_checks_get_cmds`; stub `config_get`/`config_set` with a file-backed store and stub `prompt_line` to feed answers:

```bash
F="$HOME/repo/dotfiles/bin/src/agent-session/agent-session.sh"
T="$TMPDIR/t2"; mkdir -p "$T"; STORE="$T/store"; : > "$STORE"
{
  echo 'set -uo pipefail'
  echo 'config_get() { grep -m1 "^$1=" "'"$STORE"'" 2>/dev/null | sed "s/^[^=]*=//"; }'
  echo 'config_set() { grep -v "^$1=" "'"$STORE"'" > "'"$STORE"'.t" 2>/dev/null || true; mv "'"$STORE"'.t" "'"$STORE"'"; echo "$1=$2" >> "'"$STORE"'"; }'
  # prompt_line stub: pop answers from $ANSWERS (newline-separated) via a counter file
  echo 'prompt_line() { head -n $(( $(cat "'"$T"'/n" 2>/dev/null || echo 0)+1 )) "'"$T"'/answers" | tail -1; echo $(( $(cat "'"$T"'/n" 2>/dev/null || echo 0)+1 )) > "'"$T"'/n"; }'
  echo 'have_tty() { return 0; }'
  echo "git() { echo '/repo/alltrails_android_2/.git'; }"  # git-common-dir stub
  sed -n '/^pr_repo_key() {/,/^}/p' "$F"
  sed -n '/^pr_checks_get_cmds() {/,/^}/p' "$F"
} > "$T/lib.sh"
printf './gradlew :app:assembleAlphaDebug\n./gradlew testAlphaDebugUnitTest\n./gradlew detekt\n' > "$T/answers"
echo 0 > "$T/n"
echo "=== first call: prompts, persists, prints 3 lines ==="
bash -c "source '$T/lib.sh'; pr_checks_get_cmds /repo/alltrails_android_2"
echo "=== store now populated ==="; cat "$STORE"
echo "=== second call: no prompt, same output ==="
echo 999 > "$T/n"  # if it prompts again it'd read past answers -> empty; proves it didn't
bash -c "source '$T/lib.sh'; pr_checks_get_cmds /repo/alltrails_android_2"
```

- [ ] **Step 2: Run to verify it fails**

Run: `bash "$TMPDIR/t2/../t2run.sh"` (put the above in a file and run)
Expected: FAIL (functions undefined).

- [ ] **Step 3: Implement** near the other config helpers:

```bash
# Stable per-repo key for config (basename of the OWNING repo, worktree-safe).
pr_repo_key() {
    local repo="$1" common
    common=$(git -C "$repo" rev-parse --git-common-dir 2>/dev/null || true)
    if [[ "$common" == */.git ]]; then
        basename "$(cd "$(dirname "$common")" 2>/dev/null && pwd -P)"
    else
        basename "$repo"
    fi
}

# AllTrails-flavored defaults, shown as suggestions on first configure.
pr_checks_default() {
    case "$1" in
        build) echo "./gradlew :app:assembleAlphaDebug" ;;
        test)  echo "./gradlew testAlphaDebugUnitTest" ;;
        lint)  echo "./gradlew detekt" ;;
    esac
}

# Prompt for build/test/lint commands and persist them. Blank => skip that check.
pr_checks_configure() {
    local repo="$1" key kind def val
    key=$(pr_repo_key "$repo")
    echo "Configure build/lint/test commands for repo '$key' (blank = skip that check):"
    for kind in build test lint; do
        def=$(pr_checks_default "$kind")
        val=$(prompt_line "  ${kind} command [${def}]: ")
        [[ -z "$val" ]] && val="$def"
        config_set "pr.checks.${kind}.${key}" "$val"
    done
}

# Echo three lines (build/test/lint); configure on first use.
pr_checks_get_cmds() {
    local repo="$1" key b
    key=$(pr_repo_key "$repo")
    b=$(config_get "pr.checks.build.${key}" 2>/dev/null || true)
    if [[ -z "$b" ]] && ! config_get "pr.checks.test.${key}" >/dev/null 2>&1; then
        pr_checks_configure "$repo"
    fi
    config_get "pr.checks.build.${key}" 2>/dev/null || true; echo
    config_get "pr.checks.test.${key}"  2>/dev/null || true; echo
    config_get "pr.checks.lint.${key}"  2>/dev/null || true; echo
}
```

> Note: verify the real `config_get`/`config_set` key syntax in the file and match it (keys may need sanitizing — dots are fine if the config store is line-based `key=value`; adjust separator if the existing store differs).

- [ ] **Step 4: Run to verify it passes** — Expected: first call prints the 3 commands and populates the store; second call prints the same 3 without consuming new answers.

- [ ] **Step 5: `bash -n` + commit**
```bash
git add -A && git commit -m "feat(gas pr): per-repo remembered build/lint/test commands"
```

---

### Task 3: `pr_checks` — run the commands, gate on failure

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (add `pr_checks`)

**Interfaces:**
- Consumes: `pr_checks_get_cmds`, `confirm`.
- Produces: `pr_checks <repo> <yes>` → runs each non-empty command in `$repo`; returns 0 if all pass (or user opts out), non-zero on first failure.

- [ ] **Step 1: Write the failing test** — a passing set returns 0, a failing command returns non-zero and names the failing stage. Harness stubs `pr_checks_get_cmds` to echo commands, `confirm` to yes:

```bash
F="$HOME/repo/dotfiles/bin/src/agent-session/agent-session.sh"; T="$TMPDIR/t3"; mkdir -p "$T"
mk() {
  { echo 'set -uo pipefail'
    echo "pr_checks_get_cmds() { printf '%s\n' \"$1\" \"$2\" \"$3\"; }"
    echo 'confirm() { return 0; }'
    sed -n '/^pr_checks() {/,/^}/p' "$F"
  } > "$T/lib.sh"
}
mk "true" "true" "true"
bash -c "source '$T/lib.sh'; pr_checks /tmp false; echo rc=\$?"   # expect rc=0
mk "true" "false" "true"
bash -c "source '$T/lib.sh'; pr_checks /tmp false; echo rc=\$?" 2>&1 | grep -qi "test" && echo NAMED-FAIL
```

- [ ] **Step 2: Run to verify it fails** — Expected: `pr_checks` undefined.

- [ ] **Step 3: Implement:**

```bash
# Run stored build/lint/test commands in $repo; gate on first failure.
# Interactive: asks whether to run checks at all (unless $yes).
pr_checks() {
    local repo="$1" yes="${2:-false}" cmds build test lint kind cmd rc
    if [[ "$yes" != true ]] && ! confirm "Run build / lint / tests before opening the PR?"; then
        echo "Skipping local checks (you chose not to run them)."
        return 0
    fi
    cmds=$(pr_checks_get_cmds "$repo")
    build=$(printf '%s\n' "$cmds" | sed -n '1p')
    test=$(printf '%s\n'  "$cmds" | sed -n '2p')
    lint=$(printf '%s\n'  "$cmds" | sed -n '3p')
    for kind in build test lint; do
        eval "cmd=\$$kind"
        [[ -z "$cmd" ]] && { echo "• ${kind}: (none configured — skipped)"; continue; }
        echo "• ${kind}: $cmd"
        if ! ( cd "$repo" && eval "$cmd" ); then
            echo "Error: ${kind} check failed: $cmd" >&2
            echo "Fix and re-run 'gas pr'." >&2
            return 1
        fi
    done
    echo "All configured checks passed."
    return 0
}
```

- [ ] **Step 4: Run to verify it passes** — Expected: all-`true` → `rc=0`; middle-`false` → non-zero and output contains "test".

- [ ] **Step 5: commit** — `git commit -am "feat(gas pr): run + gate on local checks"`

---

### Task 4: `pr_ticket` — derive from branch or fzf-pick

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (add `pr_branch_ticket`, `pr_ticket`)

**Interfaces:**
- Consumes: `jira_fetch_sprint_json`, `jira_pick_ticket`, `jira_ticket_details`, `confirm`.
- Produces:
  - `pr_branch_ticket <branch>` → echoes a JIRA key if the branch encodes one (`<x>/<KEY>/<...>` or `<KEY>-...` where KEY = `[A-Z][A-Z0-9]+-[0-9]+`), else empty.
  - `pr_ticket <branch> <ticket_arg>` → echoes the resolved KEY (may prompt/pick); non-zero if none chosen.

- [ ] **Step 1: Write the failing test** for `pr_branch_ticket` (pure logic):

```bash
F="$HOME/repo/dotfiles/bin/src/agent-session/agent-session.sh"; T="$TMPDIR/t4"; mkdir -p "$T"
{ echo 'set -uo pipefail'; sed -n '/^pr_branch_ticket() {/,/^}/p' "$F"; } > "$T/lib.sh"
b() { bash -c "source '$T/lib.sh'; pr_branch_ticket '$1'"; }
[ "$(b pat/DISCO-1234/fix-footer)" = "DISCO-1234" ] && echo OK1 || echo FAIL1
[ "$(b GROW-12082-tdp-cta)" = "GROW-12082" ] && echo OK2 || echo FAIL2
[ -z "$(b agent-alltrails-foo-20260101-1)" ] && echo OK3 || echo FAIL3
```

- [ ] **Step 2: Run to verify it fails** — Expected: undefined function.

- [ ] **Step 3: Implement:**

```bash
# Extract a JIRA key (e.g. DISCO-1234) from a branch name, if present.
pr_branch_ticket() {
    printf '%s' "$1" | grep -oE '[A-Z][A-Z0-9]+-[0-9]+' | head -1 || true
}

# Resolve the PR's JIRA ticket: explicit arg > branch-encoded (confirm) > fzf pick.
pr_ticket() {
    local branch="$1" arg="${2:-}" key json
    if [[ -n "$arg" ]]; then printf '%s' "$arg"; return 0; fi
    key=$(pr_branch_ticket "$branch")
    if [[ -n "$key" ]] && confirm "Use ticket ${key} (from branch name)?"; then
        printf '%s' "$key"; return 0
    fi
    json=$(jira_fetch_sprint_json)
    if [[ -z "$json" || "$json" == "[]" ]]; then
        echo "No assigned open-sprint tickets found." >&2
        return 1
    fi
    key=$(jira_pick_ticket "$json") || return 1
    [[ -z "$key" ]] && { echo "No ticket selected." >&2; return 1; }
    printf '%s' "$key"
}
```

- [ ] **Step 4: Run to verify it passes** — Expected: OK1/OK2/OK3.

- [ ] **Step 5: commit** — `git commit -am "feat(gas pr): resolve JIRA ticket (branch or fzf pick)"`

---

### Task 5: `pr_rename_branch` — rename to `{initials}/{TICKET}/{slug}`

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (add `pr_initials`, `pr_rename_branch`)

**Interfaces:**
- Consumes: `jira_branch_slug`.
- Produces:
  - `pr_initials` → lowercase initials from `git config user.name` (fallback email local-part).
  - `pr_rename_branch <current_branch> <ticket> <title>` → echoes the (possibly new) branch name; renames via `git branch -m` unless the branch already matches `*/<TICKET>/*`.

- [ ] **Step 1: Write the failing test** — idempotency + shape. Stub `git` to capture `branch -m` and report `show-current`; stub `jira_branch_slug`:

```bash
F="$HOME/repo/dotfiles/bin/src/agent-session/agent-session.sh"; T="$TMPDIR/t5"; mkdir -p "$T"
{ echo 'set -uo pipefail'
  echo 'jira_branch_slug() { echo "add-save-button"; }'
  echo 'pr_initials() { echo "pb"; }'
  echo 'git() { echo "git $*" >> "'"$T"'/calls"; return 0; }'
  sed -n '/^pr_rename_branch() {/,/^}/p' "$F"
} > "$T/lib.sh"
: > "$T/calls"
echo "=== auto branch -> renamed ==="
bash -c "source '$T/lib.sh'; pr_rename_branch 'agent-at-foo-2026-1' 'DISCO-1234' 'Add save button'"
grep -q 'branch -m .*pb/DISCO-1234/add-save-button' "$T/calls" && echo RENAMED || echo FAIL
: > "$T/calls"
echo "=== already conventional -> no rename ==="
out=$(bash -c "source '$T/lib.sh'; pr_rename_branch 'pb/DISCO-1234/existing' 'DISCO-1234' 'Add save button'")
[ "$out" = "pb/DISCO-1234/existing" ] && ! grep -q 'branch -m' "$T/calls" && echo IDEMPOTENT || echo FAIL
```

- [ ] **Step 2: Run to verify it fails** — Expected: undefined.

- [ ] **Step 3: Implement:**

```bash
pr_initials() {
    local name init
    name=$(git config user.name 2>/dev/null || true)
    [[ -z "$name" ]] && name=$(git config user.email 2>/dev/null | sed 's/@.*//' || true)
    # Initials from words; fallback to first two letters.
    init=$(printf '%s' "$name" | awk '{for(i=1;i<=NF;i++)printf substr($i,1,1)}')
    [[ -z "$init" ]] && init=$(printf '%s' "$name" | cut -c1-2)
    printf '%s' "$init" | tr '[:upper:]' '[:lower:]'
}

# Rename the auto branch to {initials}/{TICKET}/{slug}; idempotent if already so.
pr_rename_branch() {
    local cur="$1" ticket="$2" title="$3" init slug new
    case "$cur" in
        */"$ticket"/*) printf '%s' "$cur"; return 0 ;;
    esac
    init=$(pr_initials)
    slug=$(jira_branch_slug "$title")
    new="${init}/${ticket}/${slug}"
    git branch -m "$new" 2>/dev/null || { echo "Warning: could not rename branch to $new; keeping $cur." >&2; printf '%s' "$cur"; return 0; }
    printf '%s' "$new"
}
```

- [ ] **Step 4: Run to verify it passes** — Expected: RENAMED and IDEMPOTENT.

- [ ] **Step 5: commit** — `git commit -am "feat(gas pr): rename branch to convention"`

---

### Task 6: `pr_review` — headless `/code-review` (advisory)

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (add `pr_review`)

**Interfaces:**
- Consumes: `confirm`.
- Produces: `pr_review <base> <yes>` → runs the review, prints output, returns 0 (advisory) unless the user declines to proceed (then non-zero to abort).

- [ ] **Step 1: Write the failing test** — with `claude` stubbed to print findings and `confirm` stubbed, review runs and honors the proceed choice:

```bash
F="$HOME/repo/dotfiles/bin/src/agent-session/agent-session.sh"; T="$TMPDIR/t6"; mkdir -p "$T"
mkrev() {
  { echo 'set -uo pipefail'
    echo 'command() { [ "$2" = claude ] && return 0 || return 1; }'  # pretend claude exists
    echo 'claude() { echo "REVIEW: looks fine"; }'
    echo "confirm() { return $1; }"  # 0=yes 1=no injected below
    sed -n '/^pr_review() {/,/^}/p' "$F"
  } > "$T/lib.sh"
}
mkrev; sed -i.bak 's/confirm() { return \$1; }/confirm() { return 0; }/' "$T/lib.sh"
bash -c "source '$T/lib.sh'; pr_review develop false; echo rc=\$?" 2>&1 | tee "$T/o1"
grep -q 'REVIEW: looks fine' "$T/o1" && grep -q 'rc=0' "$T/o1" && echo PASS-PROCEED
mkrev; sed -i.bak 's/confirm() { return \$1; }/confirm() { return 1; }/' "$T/lib.sh"
bash -c "source '$T/lib.sh'; pr_review develop false; echo rc=\$?" 2>&1 | grep -q 'rc=1' && echo PASS-ABORT
```

- [ ] **Step 2: Run to verify it fails** — Expected: undefined.

- [ ] **Step 3: Implement** (use the `/code-review` skill; read-only allowlist; graceful fallback):

```bash
# Advisory agentic code review of the diff vs base. Uses the /code-review skill
# headless with a read-only tool allowlist. Returns non-zero only if the user
# chooses NOT to proceed after seeing findings.
pr_review() {
    local base="$1" yes="${2:-false}" out
    if ! command -v claude &>/dev/null; then
        echo "Note: 'claude' not found — skipping agentic code review." >&2
        return 0
    fi
    if [[ "$yes" != true ]] && ! confirm "Run an agentic code review of the diff vs ${base}?"; then
        return 0
    fi
    echo "Running code review (this may take a moment)…"
    out=$(claude -p "/code-review" \
        --allowedTools Read Grep Glob "Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)" \
        2>/dev/null) || {
        # Fallback: built-in review prompt with the same allowlist.
        out=$(claude -p "Review the code changes in \`git diff origin/${base}...HEAD\` for correctness bugs, missed edge cases, and convention violations. Be concise; list concrete findings." \
            --allowedTools Read Grep Glob "Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)" \
            2>/dev/null) || { echo "Note: code review failed to run — continuing." >&2; return 0; }
    }
    printf '\n----- Code review -----\n%s\n-----------------------\n\n' "$out"
    if [[ "$yes" == true ]]; then return 0; fi
    confirm "Proceed to open the PR despite any findings above?" || { echo "Aborted after review." >&2; return 1; }
    return 0
}
```

- [ ] **Step 4: Run to verify it passes** — Expected: PASS-PROCEED and PASS-ABORT.

- [ ] **Step 5: commit** — `git commit -am "feat(gas pr): advisory agentic code review"`

---

### Task 7: `pr_template` + `pr_generate` — build title & body

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (add `pr_template`, `pr_generate`, `pr_split_output`)

**Interfaces:**
- Consumes: `get_jira_subdomain`, `jira_ticket_details`.
- Produces:
  - `pr_template <repo>` → echoes the PR template text (repo template, else built-in fallback).
  - `pr_generate <repo> <base> <ticket> <summary> <title_file> <body_file>` → writes generated title to `$title_file`, body to `$body_file`. Uses `claude -p` (read-only allowlist). Body has the Jira URL filled, Technical Description written, AI-usage disclosure appended, template placeholders otherwise preserved.
  - `pr_split_output <raw_file> <title_file> <body_file>` → splits generator output on the sentinel `===PR-BODY===` (first line = title).

- [ ] **Step 1: Write the failing test** for template fallback + split parsing (pure logic; no claude):

```bash
F="$HOME/repo/dotfiles/bin/src/agent-session/agent-session.sh"; T="$TMPDIR/t7"; mkdir -p "$T"
{ echo 'set -uo pipefail'
  sed -n '/^pr_template() {/,/^}/p' "$F"
  sed -n '/^pr_split_output() {/,/^}/p' "$F"
} > "$T/lib.sh"
# Template fallback when repo has none:
mkdir -p "$T/emptyrepo"
bash -c "source '$T/lib.sh'; pr_template '$T/emptyrepo'" | grep -qi "Technical Description" && echo TEMPLATE-FALLBACK-OK
# Split parsing:
printf 'Add save-to-list button\n===PR-BODY===\n### JIRA\nbody here\n' > "$T/raw"
bash -c "source '$T/lib.sh'; pr_split_output '$T/raw' '$T/title' '$T/body'"
[ "$(cat "$T/title")" = "Add save-to-list button" ] && grep -q 'body here' "$T/body" && echo SPLIT-OK
```

- [ ] **Step 2: Run to verify it fails** — Expected: undefined.

- [ ] **Step 3: Implement:**

```bash
# Echo the repo's PR template, or a minimal built-in fallback.
pr_template() {
    local repo="$1" f
    for f in ".github/pull_request_template.md" ".github/PULL_REQUEST_TEMPLATE.md" \
             "docs/pull_request_template.md"; do
        if [[ -f "$repo/$f" ]]; then cat "$repo/$f"; return 0; fi
    done
    cat <<'EOF'
### Technical Description

🔴TBD

### Testing

🔴TBD
EOF
}

# Split "<title>\n===PR-BODY===\n<body...>" into two files.
pr_split_output() {
    local raw="$1" title_file="$2" body_file="$3"
    head -1 "$raw" > "$title_file"
    awk 'f{print} /^===PR-BODY===$/{f=1}' "$raw" > "$body_file"
}

# Generate title+body with claude (read-only allowlist) from diff+ticket+template.
pr_generate() {
    local repo="$1" base="$2" ticket="$3" summary="$4" title_file="$5" body_file="$6"
    local sub url tmpl raw prompt
    sub=$(get_jira_subdomain 2>/dev/null || true)
    url="https://${sub:-alltrails}.atlassian.net/browse/${ticket}"
    tmpl=$(pr_template "$repo")
    raw="${TMPDIR:-/tmp}/gas-pr-raw.$$"
    prompt=$(cat <<EOF
You are drafting a GitHub PR for the current branch. Base branch: ${base}.
JIRA ticket: ${ticket} — ${summary}
JIRA URL: ${url}

Use \`git diff origin/${base}...HEAD\` and \`git log origin/${base}..HEAD\` to understand the change.

Output EXACTLY this format:
<one-line PR title: imperative, <=50 chars, may prefix with feat:/fix:/etc, reference ${ticket}>
===PR-BODY===
<the PR body>

For the body, START from this repo template and fill it in, PRESERVING any lines
that are 'required verbatim for release automation' (e.g. the '----------' separator
and its surrounding comment block):
--- TEMPLATE START ---
${tmpl}
--- TEMPLATE END ---

Rules for the body:
- Put ${url} on the JIRA link line (replace any 🔴TBD there).
- Write the Technical Description from the actual diff (what changed and why).
- Leave Screenshots and A11y checklist items as unchecked placeholders for the human.
- Append an '### AI Usage' section with: Logic Summary (plain-English what the code does),
  Prompt Disclosure (that this was drafted with an AI agent via 'gas pr'), and a
  Safety Check line confirming no secrets/PII were shared.
- Do not invent screenshots or fabricate test results.
EOF
)
    if ! claude -p "$prompt" \
        --allowedTools Read Grep Glob "Bash(git diff:*)" "Bash(git log:*)" "Bash(git show:*)" \
        > "$raw" 2>/dev/null; then
        echo "Error: PR body generation failed." >&2
        rm -f "$raw"; return 1
    fi
    pr_split_output "$raw" "$title_file" "$body_file"
    rm -f "$raw"
    # Guard: non-empty title/body.
    [[ -s "$title_file" && -s "$body_file" ]] || { echo "Error: generated PR title/body was empty." >&2; return 1; }
}
```

- [ ] **Step 4: Run to verify it passes** — Expected: TEMPLATE-FALLBACK-OK and SPLIT-OK.

- [ ] **Step 5: commit** — `git commit -am "feat(gas pr): template discovery + title/body generation"`

---

### Task 8: `pr_publish` — edit, then create/update the PR (dry-run aware)

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (add `pr_publish`)

**Interfaces:**
- Consumes: `resolve_editor`, `confirm`, `open_url`.
- Produces: `pr_publish <repo> <branch> <base> <title_file> <body_file> <dry_run> <yes>` → opens the body in the editor (interactive), then pushes + `gh pr create` (draft unless user opts for ready), or prints the command under dry-run; updates an existing PR if one exists.

- [ ] **Step 1: Write the failing test** — dry-run prints the `gh pr create` command and does NOT call push/create; editor + confirm stubbed:

```bash
F="$HOME/repo/dotfiles/bin/src/agent-session/agent-session.sh"; T="$TMPDIR/t8"; mkdir -p "$T"
printf 'Add save button' > "$T/title"; printf '### JIRA\n' > "$T/body"
{ echo 'set -uo pipefail'
  echo 'resolve_editor() { echo true; }'         # editor = no-op
  echo 'confirm() { return 0; }'                  # yes to draft, etc.
  echo 'open_url() { :; }'
  echo 'command() { return 0; }'                  # gh present
  echo 'gh() { if [ "$1" = pr ] && [ "$2" = view ]; then return 1; fi; echo "gh $*" >> "'"$T"'/calls"; }'
  echo 'git() { echo "git $*" >> "'"$T"'/calls"; }'
  sed -n '/^pr_publish() {/,/^}/p' "$F"
} > "$T/lib.sh"
: > "$T/calls"
bash -c "source '$T/lib.sh'; pr_publish /tmp mybr develop '$T/title' '$T/body' true false" 2>&1 | tee "$T/o"
grep -q 'gh pr create' "$T/o" && echo PRINTS-CMD
! grep -q 'git push' "$T/calls" && echo NO-PUSH-IN-DRYRUN
```

- [ ] **Step 2: Run to verify it fails** — Expected: undefined.

- [ ] **Step 3: Implement:**

```bash
pr_publish() {
    local repo="$1" branch="$2" base="$3" title_file="$4" body_file="$5" dry="$6" yes="$7"
    local title editor draft_flag existing url cmd
    title=$(cat "$title_file")

    # Interactive edit of the body (this IS the nvim step).
    if [[ "$yes" != true ]] && confirm "Edit the PR description in your editor before publishing?"; then
        editor=$(resolve_editor) || { echo "No editor found. Set \$EDITOR (e.g. export EDITOR=nvim)." >&2; }
        [[ -n "$editor" ]] && "$editor" "$body_file" < /dev/tty > /dev/tty 2>&1 || true
    fi

    if ! command -v gh &>/dev/null; then
        echo "Error: gh CLI not found — cannot create the PR." >&2; return 1
    fi

    # Draft by default; offer ready.
    draft_flag="--draft"
    if [[ "$yes" != true ]] && confirm "Create as a DRAFT PR? (No = ready for review)"; then
        draft_flag="--draft"
    elif [[ "$yes" != true ]]; then
        draft_flag=""
    fi

    # Update existing PR if present.
    existing=$( (cd "$repo" && gh pr view "$branch" --json url --jq .url) 2>/dev/null || true )
    if [[ -n "$existing" ]]; then
        echo "A PR already exists for '$branch': $existing"
        if [[ "$dry" == true ]]; then
            echo "[dry-run] would run: gh pr edit \"$branch\" --title <title> --body-file <body>"
            return 0
        fi
        if [[ "$yes" == true ]] || confirm "Update its title/body?"; then
            (cd "$repo" && gh pr edit "$branch" --title "$title" --body-file "$body_file") && open_url "$existing"
        fi
        return 0
    fi

    if [[ "$dry" == true ]]; then
        echo "[dry-run] would run:"
        echo "  git -C $repo push -u origin $branch"
        echo "  gh pr create --base $base --head $branch --title \"$title\" --body-file $body_file $draft_flag"
        return 0
    fi

    (cd "$repo" && git push -u origin "$branch") || { echo "Error: git push failed." >&2; return 1; }
    url=$( (cd "$repo" && gh pr create --base "$base" --head "$branch" --title "$title" --body-file "$body_file" $draft_flag) ) \
        || { echo "Error: gh pr create failed." >&2; return 1; }
    echo "Created PR: $url"
    [[ "$yes" == true ]] || { confirm "Open in browser?" && open_url "$url"; }
}
```

- [ ] **Step 4: Run to verify it passes** — Expected: PRINTS-CMD and NO-PUSH-IN-DRYRUN.

- [ ] **Step 5: commit** — `git commit -am "feat(gas pr): edit + create/update PR (dry-run aware)"`

---

### Task 9: Wire the orchestrator + end-to-end dry-run test

**Files:**
- Modify: `bin/src/agent-session/agent-session.sh` (fill `cmd_pr` body to call the stages)

**Interfaces:**
- Consumes: all `pr_*` from Tasks 2–8.

- [ ] **Step 1: Write the failing e2e test** — a real worktree with a change; `claude`/`gh` stubbed via PATH shims; assert the pipeline reaches publish and prints the dry-run `gh pr create`. Create `"$TMPDIR/t9.sh"`:

```bash
set -e
BIN="$HOME/repo/dotfiles/bin/gas"
T="$TMPDIR/t9"; rm -rf "$T"; mkdir -p "$T/shims" "$T/repo"
# PATH shims for external agents/tools:
cat > "$T/shims/claude" <<'S'
#!/usr/bin/env bash
# print title + body sentinel for generate; anything for review
if printf '%s' "$*" | grep -q 'PR-BODY'; then :; fi
echo "Add save-to-list button"; echo "===PR-BODY==="; echo "### JIRA"; echo "https://x.atlassian.net/browse/DISCO-1"
S
chmod +x "$T/shims/claude"
cat > "$T/shims/gh" <<'S'
#!/usr/bin/env bash
[ "$1 $2" = "pr view" ] && exit 1   # no existing PR
echo "gh $*"
S
chmod +x "$T/shims/gh"
# Minimal git repo with origin/develop and a diff:
cd "$T/repo"; git init -q -b develop; git config user.name "Pat Beagan"; git config user.email pb@x.com
echo hi > a.txt; git add .; git commit -qm init
git clone -q --bare . "$T/origin.git"; git remote add origin "$T/origin.git"; git fetch -q origin
git symbolic-ref refs/remotes/origin/HEAD refs/remotes/origin/develop
git checkout -qb agent-x-2026; echo change >> a.txt; git commit -qam change
# Preseed check commands so no prompt; ticket via --ticket; dry-run; --yes:
export AGENT_SESSION_REGISTRY="$T/reg"
PATH="$T/shims:$PATH" "$BIN" pr --ticket DISCO-1 --dry-run --yes 2>&1 | tee "$T/out"
grep -q 'gh pr create' "$T/out" && echo E2E-OK || echo E2E-FAIL
```

> Note: the checks step with `--yes` still needs commands; either preseed config in this test or ensure `--yes` treats unconfigured checks as "skip". Implement `--yes` ⇒ skip interactive configure and skip unconfigured checks (don't prompt). Adjust `pr_checks`/`pr_checks_get_cmds` to accept a "non-interactive" mode that returns empty commands rather than prompting.

- [ ] **Step 2: Run to verify it fails** — Expected: pipeline stops early (stages not wired).

- [ ] **Step 3: Fill `cmd_pr`** — replace the "Stages wired in later tasks" comment with:

```bash
    pr_review "$base" "$pr_yes" || return 1
    pr_checks "$repo" "$pr_yes" || return 1

    local ticket summary
    ticket=$(pr_ticket "$branch" "$pr_ticket_arg") || return 1
    summary=$(jira_ticket_details "$ticket" 2>/dev/null | head -1 || true)

    local title_file body_file
    title_file="${TMPDIR:-/tmp}/gas-pr-title.$$"
    body_file="${TMPDIR:-/tmp}/gas-pr-body.$$"
    pr_generate "$repo" "$base" "$ticket" "$summary" "$title_file" "$body_file" || return 1

    branch=$(pr_rename_branch "$branch" "$ticket" "$(cat "$title_file")")

    pr_publish "$repo" "$branch" "$base" "$title_file" "$body_file" "$pr_dry_run" "$pr_yes"
    local rc=$?
    rm -f "$title_file" "$body_file"
    return $rc
```

- [ ] **Step 4: Make `--yes` non-interactive-safe** — thread a "non-interactive" signal so `pr_checks_get_cmds` returns empty (skips checks) instead of prompting when `$pr_yes` is true and nothing is configured. Update `pr_checks` to pass `yes` down and short-circuit configure.

- [ ] **Step 5: Run to verify it passes**

Run: `bash "$TMPDIR/t9.sh"`
Expected: `E2E-OK` (prints the dry-run `gh pr create` with base develop and the generated title).

- [ ] **Step 6: commit** — `git commit -am "feat(gas pr): wire orchestrator + e2e dry-run"`

---

### Task 10: Docs + roadmap

**Files:**
- Modify: `bin/src/agent-session/README.md` (document `gas pr`)
- Modify: `bin/src/agent-session/script.meta.yaml` (add a `pr` roadmap entry, marked DONE)

- [ ] **Step 1: README** — add a `### PR creation — `pr`` section describing the pipeline, the interactive prompts, the small flag set, the per-repo remembered check commands (and how to reconfigure: delete/edit the `pr.checks.*` config keys), and that PRs are created as drafts by default. Add a `pr` row to the subcommands list and the options where relevant.

- [ ] **Step 2: script.meta.yaml** — add an entry:

```yaml
  - "gas pr — DONE: guided PR creation (review, checks, jira pick, template-filled draft PR via gh)"
```

- [ ] **Step 3: commit** — `git commit -am "docs(gas pr): document the PR flow + roadmap"`

---

## Self-Review

**Spec coverage:**
- Agentic code review on diff from develop → Task 6 (`pr_review`, `/code-review` skill, advisory). ✔
- Build/lint/tests pass (gating) → Tasks 2–3 (`pr_checks_*`, gate on exit). ✔ (per updated guidance: prompt-once-and-remember, gas-run.)
- fzf ticket pick via gas jira → Task 4 (`pr_ticket` reuses `jira_pick_ticket`). ✔
- Read PR template from repo → Task 7 (`pr_template`). ✔
- Generate title+description from data+template → Task 7 (`pr_generate`). ✔
- Edit with nvim before publish → Task 8 (`pr_publish` editor step). ✔
- CONTRIBUTING context (Jira link, AI disclosure, draft, branch convention, base develop) → Global Constraints + Tasks 5,7,8. ✔
- Interactivity over flags → Global Constraints + interactive confirms throughout. ✔

**Placeholder scan:** Tests and code are concrete. The one `🔴TBD` string is intentional literal template content, not a plan placeholder.

**Type/name consistency:** `pr_checks_get_cmds`, `pr_repo_key`, `pr_branch_ticket`, `pr_ticket`, `pr_initials`, `pr_rename_branch`, `pr_review`, `pr_template`, `pr_split_output`, `pr_generate`, `pr_publish`, `cmd_pr` — names used consistently across tasks and the orchestrator wiring in Task 9. Sentinel `===PR-BODY===` used consistently in Task 7 generate + split and Task 9 test stub.

**Known follow-up (flagged in Task 9):** the non-interactive (`--yes`) path must make unconfigured checks skip rather than prompt — implemented in Task 9 Step 4.
