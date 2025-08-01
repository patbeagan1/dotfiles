switchoc () { git switch "$1" 2>/dev/null || git switch -c "$1"; git fetch "$1" 2>/dev/null; }
alias gitl='git last --oneline | cat'
alias gss='git status -sb'
alias revert-file='git checkout origin/develop --'
alias revert-files='find . -exec git checkout origin/develop -- {} \;'

alias lb="last_branch.sh | tail -10"
alias lbb="last_branch.sh | grep -v old"
alias lbf="git branch --sort=committerdate | tail -10 | fzf --tac --no-sort | xargs git checkout"

alias git-view='git log --graph --simplify-by-decoration --pretty=format:%d --all'
alias git-view2='git log --graph --oneline --decorate --all'
alias git-view3="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold green)(%ar)%C(reset) %C(white)%s%C(reset) %C(dim white)- %an%C(reset)%C(bold yellow)%d%C(reset)' --all"
alias git-view4="git log --graph --abbrev-commit --decorate --format=format:'%C(bold blue)%h%C(reset) - %C(bold cyan)%aD%C(reset) %C(bold green)(%ar)%C(reset)%C(bold yellow)%d%C(reset)%n''          %C(white)%s%C(reset) %C(dim white)- %an%C(reset)' --all"
alias gv='git-view3'

alias g="git"
alias gpom="git push origin master"
alias gs="git status"
alias gb="git branch"
alias gco="git checkout"
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

# fzf launcher for gh (GitHub CLI) commands.
# Usage: Type 'ghf' and press Enter.
ghf() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v gh &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'gh' to be installed." >&2
    return 1
  fi

  # 2. Get a list of commands by parsing the 'gh' help output
  local commands
  commands=$(gh | grep -E '^\s+\w+:' | awk '{print $1}' | sed 's/://g')
  if [[ -z "$commands" ]]; then
    echo "Error: Could not parse commands from 'gh'." >&2
    return 1
  fi

  # 3. Set up the fzf preview command, using 'bat' if available
  local preview_cmd
  if command -v bat &> /dev/null; then
    # Use 'bat' for syntax-highlighted help text
    preview_cmd="gh {} --help | bat -l help -p --color=always"
  else
    preview_cmd="gh {} --help"
  fi

  # 4. Run fzf to let the user select a command
  local selected_command
  selected_command=$(echo "$commands" | fzf --height 50% --min-height 15 --border --prompt="GitHub CLI > " \
    --preview="$preview_cmd" \
    --preview-window='right,70%,border-left')

  # 5. If a command was selected, place it on the command line
  if [[ -n "$selected_command" ]]; then
    print -z "gh ${selected_command} "
  fi
}

# fzf launcher for git commands.
# Usage: Type 'gfh' and press Enter.
gfh() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v git &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'git' to be installed." >&2
    return 1
  fi

  # 2. Get a reliable list of all git commands
  local commands
  commands=$(ls "$(git --exec-path)" | sed 's/^git-//')
  if [[ -z "$commands" ]]; then
    echo "Error: Could not list git commands from exec-path." >&2
    return 1
  fi

  # 3. Set up the fzf preview command, using 'bat' for syntax highlighting if available
  local preview_cmd
  if command -v bat &> /dev/null; then
    preview_cmd="git help {} | bat -l help -p --color=always"
  else
    preview_cmd="git help {}"
  fi

  # 4. Run fzf to let the user select a command
  local selected_command
  selected_command=$(echo "$commands" | fzf --height 60% --min-height 20 --border --prompt="Git > " \
    --preview="$preview_cmd" \
    --preview-window='right,70%,border-left')

  # 5. If a command was selected, place it on the command line for editing
  if [[ -n "$selected_command" ]]; then
    print -z "git ${selected_command} "
  fi
}


# fzf launcher for adb commands.
# Usage: Type 'afh' and press Enter.
afh() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v adb &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'adb' to be installed." >&2
    return 1
  fi

  # 2. Get a list of commands by parsing the 'adb help' output
  local commands
  commands=$(adb help | grep -E '^\s+[a-z-]' | awk '{print $1}')
  if [[ -z "$commands" ]]; then
    echo "Error: Could not parse commands from 'adb help'." >&2
    return 1
  fi

  # 3. Set up the fzf preview command
  # Since 'adb help <command>' is not supported, we grep the main help text
  # for the highlighted command's description.
  local preview_cmd
  local grep_cmd="grep -A 3 -E '^\s+{}(\s|\[|$)'"
  if command -v bat &> /dev/null; then
    preview_cmd="adb help | $grep_cmd | bat --color=always -l man -p"
  else
    preview_cmd="adb help | $grep_cmd"
  fi

  # 4. Run fzf to let the user select a command
  local selected_command
  selected_command=$(echo "$commands" | fzf --height 50% --min-height 15 --border --prompt="ADB > " \
    --preview="$preview_cmd" \
    --preview-window='right,70%,border-left')

  # 5. If a command was selected, place it on the command line for editing
  if [[ -n "$selected_command" ]]; then
    print -z "adb ${selected_command} "
  fi
}

# fzf launcher for Android emulators.
# Usage: Type 'avd' and press Enter to select and launch an AVD.
avd() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v emulator &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'emulator' to be installed." >&2
    return 1
  fi

  # 2. Get the list of available AVDs
  local avds
  avds=$(emulator -list-avds)
  if [[ -z "$avds" ]]; then
    echo "No AVDs found. Create one with 'avdmanager create avd ...'" >&2
    return 1
  fi

  # 3. Set up the fzf preview to show the AVD's configuration
  local preview_cmd
  if command -v bat &>/dev/null; then
    preview_cmd="bat --color=always ~/.android/avd/{}.avd/config.ini"
  else
    preview_cmd="cat ~/.android/avd/{}.avd/config.ini"
  fi

  # 4. Run fzf to let the user select an AVD
  local selected_avd
  selected_avd=$(echo "$avds" | fzf --height 40% --prompt="Select AVD to launch > " \
    --preview="$preview_cmd" \
    --preview-window='right,60%,border-left')

  # 5. Launch the selected AVD in the background
  if [[ -n "$selected_avd" ]]; then
    echo "Starting AVD: $selected_avd"
    # Run in background and detach from the shell
    emulator -avd "$selected_avd" &>/dev/null & disown
  fi
}

# fzf helper for avdmanager.
# Usage: Type 'avdm' and press Enter to select an action.
avdm() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v avdmanager &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'avdmanager' to be installed." >&2
    return 1
  fi

  # 2. Define the main avdmanager commands
  local commands="list\ncreate\ndelete\nmove"

  # 3. Set up the fzf preview to show help for the selected action
  local preview_cmd
  if command -v bat &>/dev/null; then
    preview_cmd="avdmanager {} help | bat -l help -p --color=always"
  else
    preview_cmd="avdmanager {} help"
  fi

  # 4. Run fzf to let the user select an action
  local selected_cmd
  selected_cmd=$(echo -e "$commands" | fzf --height 40% --prompt="AVD Manager Action > " \
    --preview="$preview_cmd")

  # 5. Place the selected command on the terminal for editing
  if [[ -n "$selected_cmd" ]]; then
    print -z "avdmanager $selected_cmd "
  fi
}

# fzf helper for sdkmanager.
# Usage: Type 'sdkm' and press Enter to select packages to install.
sdkm() {
  # 1. Check for dependencies
  if ! command -v fzf &>/dev/null || ! command -v sdkmanager &>/dev/null; then
    echo "Error: This function requires 'fzf' and 'sdkmanager' to be installed." >&2
    return 1
  fi

  # 2. Get a list of all available and installed SDK packages
  # We use --no_https to speed up the listing process significantly.
  echo "Fetching SDK package list..."
  local packages
  packages=$(sdkmanager --list --no_https 2>/dev/null)

  # 3. Run fzf with multi-select enabled
  local selected_lines
  selected_lines=$(echo "$packages" | fzf --multi --height 70% --prompt="SDK Manager Packages > ")

  # 4. Build the install command from the selected packages
  if [[ -n "$selected_lines" ]]; then
    # Extract the first column (the package string) from each selected line
    local packages_to_install
    packages_to_install=$(echo "$selected_lines" | awk '{print $1}' | tr '\n' ' ')
    print -z "sdkmanager \"$packages_to_install\""
  fi
}


