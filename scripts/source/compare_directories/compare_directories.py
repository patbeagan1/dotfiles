#!python3

import os
import hashlib
import argparse

# Function to calculate SHA-1 hash of a file
def calculate_hash(filepath):
    hasher = hashlib.sha1()
    with open(filepath, 'rb') as f:
        buf = f.read()
        hasher.update(buf)
    return hasher.hexdigest()

# Function to get all file paths and their SHA-1 hashes in a directory
def get_files_hashes(directory):
    files_hashes = {}
    for root, dirs, files in os.walk(directory):
        for name in files:
            filepath = os.path.join(root, name)
            relative_path = os.path.relpath(filepath, start=directory)
            try:
                file_hash = calculate_hash(filepath)
                files_hashes[relative_path] = file_hash
            except Exception as e:
                print(f"Error reading {filepath}: {e}")
    return files_hashes

# Function to compare hashes between two dictionaries
def compare_hashes(dir1_hashes, dir2_hashes, dir1, dir2):
    for rel_path, hashval in dir1_hashes.items():
        if rel_path not in dir2_hashes:
            print(f"Unique file in first directory: {os.path.join(dir1, rel_path)} with hash {hashval}")
        elif dir1_hashes[rel_path] != dir2_hashes.get(rel_path, None):
            print(f"File {os.path.join(dir1, rel_path)} differs with hash\n{hashval} vs {dir2_hashes[rel_path]}")

    for rel_path, hashval in dir2_hashes.items():
        if rel_path not in dir1_hashes:
            print(f"Unique file in second directory: {os.path.join(dir2, rel_path)} with hash {hashval}")

# Set up argument parsing
parser = argparse.ArgumentParser(description='Compare files in two directories by SHA-1 hash.')
parser.add_argument('directory1', type=str, help='Path to the first directory')
parser.add_argument('directory2', type=str, help='Path to the second directory')

# Parse arguments
args = parser.parse_args()
dir1 = args.directory1
dir2 = args.directory2

# Get the file hashes for each directory
dir1_hashes = get_files_hashes(dir1)
dir2_hashes = get_files_hashes(dir2)

# Compare the hashes from both directories
compare_hashes(dir1_hashes, dir2_hashes, dir1, dir2)
