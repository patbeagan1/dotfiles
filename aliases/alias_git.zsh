# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# duplicate `release-contains` removed; see jan script.

# Moved to jan scripts/git/release-contains.yaml (`jan scripts git release-contains run`).

# alias find-release='release-contains "$(git log --oneline --color=always | fzf --ansi --preview "git show --stat {1}" | awk "{print \$1}")"'

# alias cdworktree='cd $(~/repo/incubator-agent/Incubator/monorepo agent-pipeline cd | tail -1)'

# Moved to jan scripts/git/save.yaml (`jan scripts git save run`).
# Moved to jan scripts/git/switchoc.yaml (`jan scripts git switchoc run`).
# Alias for viewing the last commit in a concise format
# alias gitl='git last --oneline | cat'
# Alias for checking the status of the git repository
# alias gss='git status -sb'
# Alias to revert a file to the version in the develop branch
# alias revert-file='git checkout origin/develop --'
# Alias to revert all files to the version in the develop branch
# alias revert-files='find . -exec git checkout origin/develop -- {} \;'

# Alias to list the last 10 branches
# `lb` is an extra jan name on jan/scripts/misc/last_branch.yaml (`jan alias`).
# Previously: last_branch.sh | tail -10
# alias lb="last_branch.sh | tail -10"
# Alias to list branches excluding those marked as old
# alias lbb="last_branch.sh | grep -v old"
# Alias to select and checkout a branch from the last 10 branches
# alias lbf="git branch --sort=committerdate | tail -10 | fzf --tac --no-sort | xargs git checkout"

# Alias to view the git log in a simplified format
# alias git-view='git log --graph --simplify-by-decoration --pretty=format:%d --all'
# Alias to view the git log with more details
# alias git-view2='git log --graph --oneline --decorate --all'
# Alias to view the git log with detailed formatting
# alias git-view3="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
# Alias to view the git log with detailed formatting and author information
# alias git-view4="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
# Default alias for viewing git log
# alias gv='git-view3'

# Alias for git command
# `g`, `gs`, `gb` are declared in jan/git.yaml and emitted by `jan alias`.
# alias g="git"
# Alias to push to the master branch
# alias gpom="git push origin master"
# Alias to check the status of the git repository
# alias gs="git status"
# Alias to list branches
# alias gb="git branch"
# Alias to checkout a branch
# alias gco="git checkout"
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
# alias getCurrentRelease="git branch -r | grep 'origin/release' | cut -d'/' -f 3-99 | grep -E '^\d+\.\d+\.\d+$' | sort -t . -k1,1n -k2,2n -k3,3n | tail -1"

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
# alias gtools="git_tools_fzf"

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

