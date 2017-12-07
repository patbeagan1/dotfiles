add-ssh-identity () 
{ 
    set -x;
    eval "$(ssh-agent -s)";
    pause Press ENTER to continue with the key ~/.ssh/id_rsa;
    ssh-add -K ~/.ssh/id_rsa;
    set +x
}
if [[ $0 != "-bash" ]]; then add-ssh-identity "$@"; fi
