# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# duplicate `release-contains` removed; see jan script.

# Moved to jan scripts/git/release-contains.yaml (`jan scripts git release-contains run`).

# Moved to jan scripts/git/save.yaml (`jan scripts git save run`).
# Moved to jan scripts/git/switchoc.yaml (`jan scripts git switchoc run`).
# Alias for viewing the last commit in a concise format
# Alias for checking the status of the git repository
# Alias to revert a file to the version in the develop branch
# Alias to revert all files to the version in the develop branch

# Alias to list the last 10 branches
# `lb` is an extra jan name on jan/scripts/misc/last_branch.yaml (`jan alias`).
# Previously: last_branch.sh | tail -10
# Alias to list branches excluding those marked as old
# Alias to select and checkout a branch from the last 10 branches

# Alias to view the git log in a simplified format
# Alias to view the git log with more details
# Alias to view the git log with detailed formatting
# Alias to view the git log with detailed formatting and author information
# Default alias for viewing git log

# Alias for git command
# `g`, `gs`, `gb` are declared in jan/git.yaml and emitted by `jan alias`.
# Alias to push to the master branch
# Alias to check the status of the git repository
# Alias to list branches
# Alias to checkout a branch
# Function to log commits over time
# Moved to jan scripts/git/git-over-time.yaml (`jan scripts git git-over-time run`).

###########################################################
# Git Configuration
###########################################################

git config --global alias.co checkout
git config --global alias.revert-file 'checkout origin/develop --'
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.unstage 'reset HEAD --'
git config --global alias.last 'log -1 HEAD'
git config --global alias.visual '!gitk'
git config --global alias.mergetest '!f(){ git merge --no-commit --no-ff "$1"; git merge --abort; echo "Merge aborted"; };f'
git config --global alias.work 'log --pretty=format:"%h%x09%an%x09%ad%x09%s"'

###########################################################
# Development
###########################################################

# Alias to get the current release version

git config --global alias.commit-ai 'git-commit-ai'
# Moved to jan scripts/git/git-commit-ai.yaml (`jan scripts git git-commit-ai run`).

# fzf wrapper to group useful git/jira/gh functions for quick access
git_tools_fzf() {
  local options=(
    "1. gh-prs-last-6-months         View your PRs from the last 6 months in this repo"
    "2. gh-prs-last-6-months-all     View your PRs from the last 6 months in multiple repos"
    "3. jirasprintmine               List your Jira issues in open sprints"
    "4. git-over-time                Show commit dates and authors"
    "5. getCurrentRelease            Show the latest release branch"
    "6. gv (git-view3)               Pretty git log graph"
    "7. gs (git status)              Show git status"
    "8. gb (git branch)              List branches"
    "9. gco (git checkout)           Checkout a branch"
    "10. lbf                         Fuzzy checkout from last 10 branches"
    "11. lbb                         Show last branch"
    "12. Exit"
  )
  local choice
  choice=$(printf '%s\n' "${options[@]}" | fzf --prompt="Select a git/jira tool: " --height=80% --border --ansi)
  case "$choice" in
    "1."*) gh-prs-last-6-months ;;
    "2."*) 
      echo "Enter repo directories (space-separated):"
      read -r repos
      gh-prs-last-6-months-all $repos
      ;;
    "3."*) jirasprintmine ;;
    "4."*) git-over-time ;;
    "5."*) getCurrentRelease ;;
    "6."*) gv ;;
    "7."*) gs ;;
    "8."*) gb ;;
    "9."*) 
      echo "Enter branch to checkout:"
      read -r branch
      gco "$branch"
      ;;
    "10."*) lbf ;;
    "11."*) lbb ;;
    *) echo "Exiting." ;;
  esac
}

# Moved to jan scripts/git/gh-prs-last-6-months-all.yaml (`jan scripts git gh-prs-last-6-months-all run`).

# Moved to jan scripts/git/gh-prs-last-6-months.yaml (`jan scripts git gh-prs-last-6-months run`).

# Moved to jan scripts/git/gh-prs-awaiting-my-review.yaml (`jan scripts git gh-prs-awaiting-my-review run`).

# These Jira helpers now live in `gas` (single implementation), which turns a
# sprint ticket into an isolated worktree + agent window instead of an in-place
# checkout. These remain as thin wrappers for muscle memory and the gtools menu.
# Moved to jan scripts/git/jirasprintmine.yaml (`jan scripts git jirasprintmine run`).

# Moved to jan scripts/git/jirabranch.yaml (`jan scripts git jirabranch run`).

# fzf launcher for gh (GitHub CLI) commands.
# Usage: Type 'ghf' and press Enter.
# Moved to jan scripts/git/ghf.yaml (`jan scripts git ghf run`).

# fzf launcher for git commands.
# Usage: Type 'gfh' and press Enter.
# Moved to jan scripts/git/gfh.yaml (`jan scripts git gfh run`).

# Stacked PR creator using GitHub CLI
# Usage: gh-stack <base-commit-or-branch>
# Moved to jan scripts/git/gh-stack.yaml (`jan scripts git gh-stack run`).
