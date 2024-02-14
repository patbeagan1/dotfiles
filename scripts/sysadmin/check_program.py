#!/usr/bin/env python3

import subprocess
from concurrent.futures import ThreadPoolExecutor
import argparse

# Define a dictionary for package managers and their respective check commands
pkg_managers = {
    'brew': 'brew list',
    'apt': 'apt list --installed',
    'yum': 'yum list installed',
    'dnf': 'dnf list --installed',
    'zypper': 'zypper se --installed-only',
    'pacman': 'pacman -Q',
    'port': 'port installed',
    'rpm': 'rpm -q',
    'snap': 'snap list',
    'flatpak': 'flatpak list',
    'npm': 'npm list -g',
    'cargo': 'cargo install --list',
    'pip': 'pip show',
    'pip3': 'pip3 show',
    'gem': 'gem list --installed',
    'pear': 'pear list',
    'composer': 'composer show',
    'nuget': 'dotnet nuget locals all --list',
    'go': 'go list -m',
    'conda': 'conda list'
}

def check_installed(manager, program):
    """
    Check if a program is installed using a specified package manager.
    
    Args:
    - manager: The package manager name.
    - program: The program name to check.
    
    Returns:
    - The package manager name if the program is installed; otherwise, an empty string.
    """
    # try:
    # Check if the package manager is available on the system
    subprocess.run(manager, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, check=True)

    # Retrieve the command for the package manager
    check_cmd = pkg_managers[manager]

    # Execute the command to check if the program is installed
    child = subprocess.Popen(f"{check_cmd} {program}", stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    print(child.stdout.read())

    result = subprocess.run(f"{check_cmd} {program}", shell=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL)

    if result.returncode == 0:
        return manager
    else:
        return ''
    # except (subprocess.CalledProcessError, KeyError, FileNotFoundError):
    #     return ''

def main(program):
    """
    Main function to check if a program is installed via various package managers.
    
    Args:
    - program: The program name to check.
    """
    print("Starting program check...")

    # Run the checks in parallel
    print("Running checks across various package managers...")
    with ThreadPoolExecutor() as executor:
        results = list(executor.map(check_installed, pkg_managers.keys(), [program] * len(pkg_managers)))
    
    # Filter out empty strings and display the package managers that have the program installed
    installed_pkg_managers = [pkg_managers[manager] for manager in results if manager]
    print(f"Program {program} is installed via the following package managers:")
    print("  "+ '\n  '.join(installed_pkg_managers) if installed_pkg_managers else f"Program {program} is not installed via known package managers or is not available.")
    
    print("Check complete.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Check if a program is installed via various package managers.")
    parser.add_argument('program', type=str, help="The name of the program to check.")
    args = parser.parse_args()

    main(args.program)
