#!/usr/bin/env python3

import os
import subprocess
import time

# ANSI code for start of line
ANSI_START_OF_LINE = '\033[0G'

def has_changes():
    """
    Checks if there are uncommitted changes in the git repository.

    Returns:
        bool: True if there are uncommitted changes, False otherwise.
    """
    try:
        output = subprocess.check_output(['git', 'status', '--porcelain'])
        return output.decode('utf-8') != ''
    except subprocess.CalledProcessError as e:
        print(f'Error checking git status: {e.output.decode("utf-8")}')
        return False

def main():
    """
    Commits changes to the git repository every minute, if there are any.
    Prints out the time of the last commit, overwriting the previous output.
    """
    # Check if current directory is a git repository
    try:
        subprocess.check_output(['git', 'rev-parse', '--is-inside-work-tree'])
    except subprocess.CalledProcessError:
        print("The current directory is not a git repository.")
        return

    while True:
        if has_changes():
            current_time = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime())
            message = f'Standard commit at {current_time}'

            try:
                print("")
                subprocess.check_call(['git', 'add', '.'])
                subprocess.check_call(['git', 'commit', '-m', message])

                print(f'{ANSI_START_OF_LINE}Last sync: {current_time}', end='', flush=True)
            except subprocess.CalledProcessError as e:
                print(f'\nError committing changes: {e.output.decode("utf-8")}')

        time.sleep(60)

if __name__ == "__main__":
    main()

