###########################################################
# command-not-found handler (Ubuntu / Homebrew / etc.)
###########################################################

# Prefer distro handler scripts when present.
for _libbeagan_cnf (
  /usr/share/doc/pkgfile/command-not-found.zsh
  /usr/share/zsh/plugins/xbps-command-not-found/xbps-command-not-found.zsh
  /opt/homebrew/Library/Homebrew/command-not-found/handler.sh
  /usr/local/Homebrew/Library/Homebrew/command-not-found/handler.sh
  /home/linuxbrew/.linuxbrew/Homebrew/command-not-found/handler.sh
); do
  if [[ -r "$_libbeagan_cnf" ]]; then
    # shellcheck disable=SC1090
    source "$_libbeagan_cnf"
    unset _libbeagan_cnf
    return 0
  fi
done
unset _libbeagan_cnf

# Debian / Ubuntu
if [[ -x /usr/lib/command-not-found || -x /usr/share/command-not-found/command-not-found ]]; then
  command_not_found_handler() {
    if [[ -x /usr/lib/command-not-found ]]; then
      /usr/lib/command-not-found -- "$1"
      return $?
    elif [[ -x /usr/share/command-not-found/command-not-found ]]; then
      /usr/share/command-not-found/command-not-found -- "$1"
      return $?
    else
      print -u2 "zsh: command not found: $1"
      return 127
    fi
  }
fi
