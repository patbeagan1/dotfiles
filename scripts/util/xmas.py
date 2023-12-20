#!/usr/bin/env python3
import random
import argparse

def create_christmas_tree(height, tree_color, bauble_color, garland_color):
    """Generate a Christmas tree ASCII art with baubles and garlands."""
    for i in range(height):
        row = ''
        for j in range(2 * i + 1):
            char = '*' if random.random() > 0.1 else 'O'
            color = bauble_color if char == 'O' else garland_color if j % 3 == 0 else tree_color
            row += f"{color}{char}\033[0m"
        print(f"{' ' * (height - i - 1)}{row}")
    print(f"{tree_color}{(' ' * (height - 1)) + '*'}\033[0m")

def convert_color(color_str):
    """Converts a color string 'R,G,B' to an ANSI escape sequence."""
    r, g, b = map(int, color_str.split(','))
    return f"\033[38;2;{r};{g};{b}m"

def parse_arguments():
    """Parse command line arguments for the script."""
    parser = argparse.ArgumentParser(description='Generate a festive Christmas tree ASCII art.')
    parser.add_argument('-H', '--height', type=int, default=10, help='Height of the Christmas tree')
    parser.add_argument('-C', '--color', type=str, default='34,139,34', help='RGB color for the tree')
    parser.add_argument('-B', '--bauble', type=str, default='255,0,0', help='RGB color for the baubles')
    parser.add_argument('-G', '--garland', type=str, default='255,215,0', help='RGB color for the garlands')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    tree_color = convert_color(args.color)
    bauble_color = convert_color(args.bauble)
    garland_color = convert_color(args.garland)
    create_christmas_tree(args.height, tree_color, bauble_color, garland_color)

