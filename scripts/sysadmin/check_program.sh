#!/bin/bash

# This script checks if a specific program is installed using various package managers.
# Usage: ./check_program.sh [program_name]

# Define an associative array for package managers and their respective check commands
declare -A pkg_managers=(
    [brew]="brew list"
    [apt]="apt list --installed 2>/dev/null | grep -q"
    [yum]="yum list installed"
    [dnf]="dnf list --installed"
    [zypper]="zypper se --installed-only"
    [pacman]="pacman -Q"
    [port]="port installed"
    [rpm]="rpm -q"
    [snap]="snap list"
    [flatpak]="flatpak list"
    [npm]="npm list -g"
    [cargo]="cargo install --list"
    [pip]="pip show"
    [pip3]="pip3 show"
    [gem]="gem list --installed"
    [pear]="pear list"
    [composer]="composer show"
    [nuget]="dotnet nuget locals all --list"
    [go]="go list -m"
    [conda]="conda list"
)

# Function to check if a program is installed using a specified package manager
# Arguments:
#   $1: Package manager name
#   $2: Program name to check
check_installed() {
    local manager=$1
    local program=$2

    # Check if the package manager is available on the system
    if ! command -v $manager &> /dev/null; then
        echo "Package manager $manager is not installed."
        return 2
    fi

    # Retrieve the command for the package manager
    local check_cmd=${pkg_managers[$manager]}
    if [ -z "$check_cmd" ]; then
        echo "Unsupported package manager: $manager"
        return 1
    fi

    # Execute the command to check if the program is installed
    if eval "$check_cmd $program" &> /dev/null; then
        return 0
    else
        return 1
    fi
}

# Check if a program name is provided
if [ $# -eq 0 ]; then
    echo "Please provide a program name."
    exit 1
fi

PROGRAM=$1
PROGRAM_INSTALLED=false

# Iterate through package managers and check if the program is installed
for manager in "${!pkg_managers[@]}"; do
    if check_installed $manager $PROGRAM; then
        echo "Program $PROGRAM is installed via $manager."
        PROGRAM_INSTALLED=true
        break
    fi
done

if ! $PROGRAM_INSTALLED; then
    echo "Program $PROGRAM is not installed via known package managers or is not available."
    exit 1
fi

