#!/usr/bin/env python3
import argparse
import random

current_line = 1
def line_print(s):
    global current_line
    print(f"{str(current_line).zfill(2)} {s}")
    current_line += 1

def create_christmas_tree(height, tree_color, bauble_color, garland_color, border_color):
    """Generate a Christmas tree ASCII art with baubles, garlands, and a festive border."""
    border = f"   {border_color}{'*' * (height * 2 + 1)}\033[0m"
    print(border)
    for i in range(height):
        row = ''
        for j in range(2 * i + 1):
            char = '*' if random.random() > 0.1 else 'O'
            color = bauble_color if char == 'O' else garland_color if j % 3 == 0 else tree_color
            row += f"{color}{char}\033[0m"
        line_print(f"{border_color}*{tree_color}{' ' * (height - i - 1)}{row}{border_color}{' ' * (height - i - 1)}*\033[0m")
    print(f"   {border_color}*{tree_color}{(' ' * (height - 1)) + '*'}{border_color}{' ' * (height - 1)}*\033[0m")
    print(border)

def convert_color(color_str):
    """Converts a color string 'R,G,B' to an ANSI escape sequence."""
    r, g, b = map(int, color_str.split(','))
    return f"\033[38;2;{r};{g};{b}m"

def parse_arguments():
    """Parse command line arguments for the script."""
    parser = argparse.ArgumentParser(description='Generate a festive Christmas tree ASCII art with a border.')
    parser.add_argument('-H', '--height', type=int, default=10, help='Height of the Christmas tree')
    parser.add_argument('-C', '--color', type=str, default='34,139,34', help='RGB color for the tree')
    parser.add_argument('-B', '--bauble', type=str, default='255,0,0', help='RGB color for the baubles')
    parser.add_argument('-G', '--garland', type=str, default='255,215,0', help='RGB color for the garlands')
    parser.add_argument('-BR', '--border', type=str, default='128,128,128', help='RGB color for the border')
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_arguments()
    tree_color = convert_color(args.color)
    bauble_color = convert_color(args.bauble)
    garland_color = convert_color(args.garland)
    border_color = convert_color(args.border)
    create_christmas_tree(args.height, tree_color, bauble_color, garland_color, border_color)

