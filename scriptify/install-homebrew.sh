install-homebrew () 
{ 
    ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
}
if [[ $0 != "-bash" ]]; then install-homebrew "$@"; fi
