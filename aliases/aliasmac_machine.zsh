# True `alias` entries were moved to the jan spec and are emitted by `jan alias`.
# Functions and conditional fallbacks stay here.
# alias mac_showFinderLocation='defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES && killall Finder'
# alias mac_hideFinderLocation='defaults write com.apple.finder _FXShowPosixPathInTitle -bool NO && killall Finder'
# alias mac_showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
# alias mac_hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'

# alias readOutLoud='say -v Moira -i -f'
# alias read_out_loud=readOutLoud

# alias java_list='/bin/zsh -lc "/usr/libexec/java_home -V 2>&1 | cat'

# JAVA_HOME aliases live on jan/system.yaml (`macos-shell`, emitted by `jan alias`).

# macOS has no `md5sum`, so use `md5` as a fallback
command -v md5sum >/dev/null || alias md5sum="md5"

# macOS has no `sha1sum`, so use `shasum` as a fallback
command -v sha1sum >/dev/null || alias sha1sum="shasum"
