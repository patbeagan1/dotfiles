#!/usr/bin/env python3 

import argparse
import os
from pathlib import Path

def create_chunked_symlinks(
    src_dir: str, 
    dest_dir: str, 
    min_size_mb: float = 0.0, 
    extra_extensions: list = None
):
    """
    Finds files matching criteria in src_dir and creates chunked symlinks in dest_dir.
    """
    IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff'}
    
    target_extensions = IMAGE_EXTENSIONS.copy()
    if extra_extensions:
        for ext in extra_extensions:
            ext = ext.lower()
            if not ext.startswith('.'):
                ext = f".{ext}"
            target_extensions.add(ext)
    
    src_path = Path(src_dir).resolve()
    dest_path = Path(dest_dir).resolve()
    
    if not src_path.exists():
        print(f"Error: Source directory '{src_path}' does not exist.")
        return

    matching_files = []
    print(f"Scanning '{src_path}' for matching files...")
    
    for file_path in src_path.rglob('*'):
        if not file_path.is_file():
            continue
            
        if file_path.suffix.lower() not in target_extensions:
            continue
            
        file_size_mb = file_path.stat().st_size / (1024 * 1024)
        if file_size_mb < min_size_mb:
            continue
            
        matching_files.append(file_path)
    
    total_files = len(matching_files)
    print(f"Found {total_files} matching files. Creating symlinks...")

    CHUNK_SIZE = 100
    for index, file_path in enumerate(matching_files):
        chunk_number = (index // CHUNK_SIZE) * CHUNK_SIZE
        chunk_dir_name = f"{chunk_number:03d}"
        
        current_chunk_dir = dest_path / chunk_dir_name
        current_chunk_dir.mkdir(parents=True, exist_ok=True)
        
        link_name = file_path.name
        link_path = current_chunk_dir / link_name
        
        if link_path.exists():
            link_path = current_chunk_dir / f"{file_path.stem}_{index}{file_path.suffix}"

        try:
            link_path.symlink_to(file_path)
        except OSError as e:
            print(f"Failed to create symlink for {file_path.name}: {e}")
            print("Note: On Windows, you may need to run this script as Administrator/enable Developer Mode.")
            return

    print(f"Done! Chunked folders created successfully inside: {dest_path}")

if __name__ == "__main__":
    # Custom text block displayed at the bottom of the --help output
    usage_examples = """
Examples of usage:
  
  1. Default Behavior (Find all images, no size limit, chunk into 100s):
     python symlink_creator.py /path/to/source /path/to/destination

  2. Filter by Minimum File Size (Include only images >= 2.5 Megabytes):
     python symlink_creator.py /path/to/source /path/to/destination --size 2.5

  3. Add Custom Extensions (Include videos and raw files alongside regular images):
     python symlink_creator.py /path/to/source /path/to/destination --ext mp4 mov cr2

  4. Combine All Filters:
     python symlink_creator.py ./my_photos ./output --size 1.0 --ext mp4 avi

OS Note:
  If you are using Windows, running symlink tools often requires administrative
  privileges. If it fails, restart your terminal as an Administrator.
    """

    # Initialize the argument parser with raw formatting to preserve our example text layout
    parser = argparse.ArgumentParser(
        description="Walks a directory tree, filters files by criteria, and builds a chunked directory of symlinks.",
        epilog=usage_examples,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )
    
    # Required Positional Arguments
    parser.add_argument(
        "src_dir", 
        help="The directory path to search recursively for target files."
    )
    parser.add_argument(
        "dest_dir", 
        help="The target root directory where chunked folders (000, 100...) will be created."
    )
    
    # Optional Flag Arguments
    parser.add_argument(
        "-s", "--size", 
        type=float, 
        default=0.0, 
        metavar="MB",
        help="Minimum file size restriction in Megabytes (MB). Files smaller than this are skipped. (Default: 0.0)"
    )
    parser.add_argument(
        "-e", "--ext", 
        nargs="+", 
        metavar="EXT",
        help="Space-separated list of additional file extensions to match (e.g., mp4 pdf). Default matches common images."
    )

    args = parser.parse_args()

    create_chunked_symlinks(
        src_dir=args.src_dir,
        dest_dir=args.dest_dir,
        min_size_mb=args.size,
        extra_extensions=args.ext
    )
