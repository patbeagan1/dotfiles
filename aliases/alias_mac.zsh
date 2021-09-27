alias mac_showFinderLocation='defaults write com.apple.finder _FXShowPosixPathInTitle -bool YES && killall Finder'
alias mac_hideFinderLocation='defaults write com.apple.finder _FXShowPosixPathInTitle -bool NO && killall Finder'
alias mac_showFiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder /System/Library/CoreServices/Finder.app'
alias mac_hideFiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder /System/Library/CoreServices/Finder.app'
