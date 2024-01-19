#!/bin/bash

# This script checks if a specific program is installed using various package managers.
# It uses GNU parallel to perform checks in parallel for speed improvement.
# Usage: ./check_program.sh [program_name]

echo "Starting program check..."

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

    echo "Checking for $program using $manager..."

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
        echo "Program $program is installed via $manager."
        return 0
    else
        return 1
    fi
}

# Export function to be used by parallel
export -f check_installed

# Check if a program name is provided
if [ $# -eq 0 ]; then
    echo "Please provide a program name."
    exit 1
fi

PROGRAM=$1
export PROGRAM

# Run the checks in parallel
echo "Running checks across various package managers..."
parallel check_installed ::: "${!pkg_managers[@]}" ::: "$PROGRAM"

echo "Check complete."

