#!/usr/bin/env python3

"""
Script Name: color_csv_display.py
Description: This script reads a CSV file and prints each column in a different ANSI color.
Usage: python color_csv_display.py -f <path_to_csv_file>
"""

import csv
import argparse

# ANSI color codes
COLORS = [
    '\033[31m',  # Red
    '\033[32m',  # Green
    '\033[33m',  # Yellow
    '\033[34m',  # Blue
    '\033[35m',  # Magenta
    '\033[36m',  # Cyan
    '\033[37m',  # White
    '\033[0m'    # Reset
]

def parse_arguments():
    """ Parse command line arguments. """
    parser = argparse.ArgumentParser(description='Display CSV file with columns in different colors.')
    parser.add_argument('-f', '--file', required=True, help='Path to the CSV file')
    return parser.parse_args()

def print_colored_csv(file_path):
    """ Read and print CSV file with each column in a different color. """
    try:
        with open(file_path, newline='') as csvfile:
            reader = csv.reader(csvfile)
            for row in reader:
                colored_row = [f"{COLORS[i % len(COLORS)]}{col}{COLORS[-1]}" for i, col in enumerate(row)]
                print(' '.join(colored_row))
    except FileNotFoundError:
        print(f"Error: File '{file_path}' not found.")
    except Exception as e:
        print(f"Error: {e}")

def main():
    args = parse_arguments()
    print_colored_csv(args.file)

if __name__ == "__main__":
    main()

