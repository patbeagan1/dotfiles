#!/usr/bin/env python3
import argparse
import random

def create_christmas_tree(height, color_code, bauble_code, garland_code):
    """Generate a Christmas tree ASCII art with baubles and garlands."""
    for i in range(height):
        row = ''
        for j in range(2 * i + 1):
            char = '*' if random.random() > 0.1 else 'O'
            color = bauble_code if char == 'O' else garland_code if j % 3 == 0 else color_code
            row += f"{color}{char}\033[0m"
        print(f"{' ' * (height - i - 1)}{row}")
    print(f"{color_code}{(' ' * (height - 1)) + '*'}\033[0m")

def parse_arguments():
    """Parse command line arguments for the script."""
    parser = argparse.ArgumentParser(description='Generate a festive Christmas tree ASCII art.')
    parser.add_argument('-H', '--height', type=int, default=10, help='Height of the Christmas tree')
    parser.add_argument('-C', '--color', type=str, default='\033[32m', help='ANSI color code for the tree')
    parser.add_argument('-B', '--bauble', type=str, default='\033[31m', help='ANSI color code for the baubles')
    parser.add_argument('-G', '--garland', type=str, default='\033[33m', help='ANSI color code for the garlands')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    create_christmas_tree(args.height, args.color, args.bauble, args.garland)

