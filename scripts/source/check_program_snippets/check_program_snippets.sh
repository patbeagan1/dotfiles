#!/usr/bin/zsh

# Local snippets
eval "$(fzf << EOF
brew list
apt list --installed
yum list installed
dnf list --installed
zypper se --installed-only
pacman -Q
port installed
rpm -q
snap list
flatpak list
npm list -g
cargo install --list
pip show
pip3 show
gem list --installed
pear list
composer show
dotnet nuget locals all --list
go list -m
conda list
EOF
)"