# Alias for viewing the last commit in a concise format
alias gitl='git last --oneline | cat'
# Alias for checking the status of the git repository
alias gss='git status -sb'
# Alias to revert a file to the version in the develop branch
alias revert-file='git checkout origin/develop --'
# Alias to revert all files to the version in the develop branch
alias revert-files='find . -exec git checkout origin/develop -- {} \;'

# Alias to list the last 10 branches
alias lb="last_branch.sh | tail -10"
# Alias to list branches excluding those marked as old
alias lbb="last_branch.sh | grep -v old"
# Alias to select and checkout a branch from the last 10 branches
alias lbf="git branch --sort=committerdate | tail -10 | fzf --tac --no-sort | xargs git checkout"

# Alias to view the git log in a simplified format
alias git-view='git log --graph --simplify-by-decoration --pretty=format:%d --all'
# Alias to view the git log with more details
alias git-view2='git log --graph --oneline --decorate --all'
# Alias to view the git log with detailed formatting
alias git-view3="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
# Alias to view the git log with detailed formatting and author information
alias git-view4="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
# Default alias for viewing git log
alias gv='git-view3'

# Alias for git command
alias g="git"
# Alias to push to the master branch
alias gpom="git push origin master"
# Alias to check the status of the git repository
alias gs="git status"
# Alias to list branches
alias gb="git branch"
# Alias to checkout a branch
alias gco="git checkout"
# Function to log commits over time
git-over-time() {  git log --format=format:'%as,%ae';  }

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
alias getCurrentRelease="git branch -r | grep 'origin/release' | cut -d'/' -f 3-99 | grep -E '^\d+\.\d+\.\d+$' | sort -t . -k1,1n -k2,2n -k3,3n | tail -1"

gh-prs-last-6-months-all() {
  if [ "$#" -eq 0 ]; then
    echo "Error: No repositories supplied."
    echo "Usage: gh-prs-last-6-months-all <repo1> <repo2> ..."
    return 1
  fi
  local repos=("$@")
  for repo in "${repos[@]}"; do
    if [ -d "$repo/.git" ]; then
      echo ""
      echo "=================================================================="
      echo "Repository: $repo"
      echo "=================================================================="
      echo ""
      (cd "$repo" && gh-prs-last-6-months)
      echo ""
    else
      echo "Directory $repo is not a git repository."
    fi
  done
}


gh-prs-last-6-months() {
  # Detect the default base branch of the local repo (e.g., develop or main or master)
  local base_branch
  if git show-ref --verify --quiet refs/remotes/origin/develop; then
    base_branch="develop"
  elif git show-ref --verify --quiet refs/remotes/origin/main; then
    base_branch="main"
  elif git show-ref --verify --quiet refs/remotes/origin/master; then
    base_branch="master"
  else
    # fallback: use current branch
    base_branch=$(git symbolic-ref --short HEAD)
  fi

  local since_date=$(date -v-6m +%Y-%m-%d)
  local until_date=$(date +%Y-%m-%d)
  
  # Ask for the GitHub username directly and remember it for future use
  local author
  if [ -f ~/.gh_prs_author ]; then
    author=$(cat ~/.gh_prs_author)
  fi
  if [ -z "$author" ]; then
    read "author?Enter your GitHub username: "
    if [ -z "$author" ]; then
      echo "GitHub username is required."
      return 1
    fi
    echo "$author" > ~/.gh_prs_author
  fi

  echo "###########################################################"
  echo "#   GitHub PRs merged in the last 6 months (by ${author})"
  echo "###########################################################"
  gh pr list --limit 1000 --search "is:pr is:closed merged:${since_date}..${until_date} base:${base_branch} author:${author} sort:updated-desc" | cat

  echo ""
  echo "###########################################################"
  echo "#   GitHub PRs merged into branches other than ${base_branch} (by ${author})"
  echo "###########################################################"
  gh pr list --search "is:pr is:closed merged:${since_date}..${until_date} -base:${base_branch} author:${author} sort:updated-desc" | cat
}