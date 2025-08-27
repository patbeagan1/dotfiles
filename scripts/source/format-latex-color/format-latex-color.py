#!/usr/bin/env python3

import argparse
import random

def colorize_text(text, method="word_by_word", colors=None, keyword_map=None):
    """
    Colorizes text for LaTeX rendering in GitHub Markdown, explicitly adding \\space.

    Args:
        text (str): The input text to colorize.
        method (str): The colorization method.
                      Options: "word_by_word", "keyword", "random".
        colors (list, optional): A list of LaTeX color names to use.
                                 Defaults to ["red", "lightblue", "orange", "green", "yellow", "blue", "purple"].
        keyword_map (dict, optional): A dictionary mapping keywords to LaTeX color names
                                      for the "keyword" method.

    Returns:
        str: The colorized text formatted for LaTeX with explicit \\space.
    """
    if colors is None:
        colors = ["red", "lightblue", "orange", "green", "yellow", "blue", "purple"]

    words = text.split()
    colorized_parts = []

    for i, word in enumerate(words):
        current_color = ""
        if method == "word_by_word":
            current_color = colors[i % len(colors)]
            colorized_parts.append(f"\\color{{{current_color}}}{word}")
        elif method == "keyword":
            if keyword_map is None:
                raise ValueError("keyword_map must be provided for 'keyword' method.")
            
            matched = False
            for keyword, color in keyword_map.items():
                if keyword.lower() in word.lower():
                    current_color = color
                    colorized_parts.append(f"\\color{{{current_color}}}{word}")
                    matched = True
                    break
            if not matched:
                colorized_parts.append(word) # Append uncolored word if no keyword match
        elif method == "random":
            current_color = random.choice(colors)
            colorized_parts.append(f"\\color{{{current_color}}}{word}")
        else:
            raise ValueError(f"Unknown colorization method: {method}")

        # Add \space after each word, except for the last one
        if i < len(words) - 1:
            colorized_parts.append(" \\space ")

    return "$$" + "".join(colorized_parts) + "$$"


def main():
    parser = argparse.ArgumentParser(
        description="Colorizes text for LaTeX rendering in GitHub Markdown.",
        formatter_class=argparse.RawTextHelpFormatter # For better formatting of help message
    )

    parser.add_argument(
        "text",
        type=str,
        help="The input text to colorize. Enclose in quotes if it contains spaces."
    )

    parser.add_argument(
        "-m", "--method",
        type=str,
        choices=["word_by_word", "keyword", "random"],
        default="word_by_word",
        help="Colorization method.\n"
             "  word_by_word: Cycle through colors for each word.\n"
             "  keyword: Color specific keywords (requires -k/--keywords).\n"
             "  random: Assign a random color to each word."
    )

    parser.add_argument(
        "-c", "--colors",
        type=str,
        nargs="*", # Allows zero or more arguments
        default=["red", "lightblue", "orange", "green", "yellow", "blue", "purple"],
        help="List of LaTeX color names (e.g., red blue green). \n"
             "  Applies to 'word_by_word' and 'random' methods."
    )

    parser.add_argument(
        "-k", "--keywords",
        type=str,
        nargs="*", # Allows zero or more arguments
        metavar="KEYWORD:COLOR",
        help="For 'keyword' method: specify keywords and their colors. \n"
             "  Format: KEYWORD1:COLOR1 KEYWORD2:COLOR2.\n"
             "  Example: API:green breaking:red"
    )

    args = parser.parse_args()

    keyword_map = None
    if args.method == "keyword":
        if not args.keywords:
            parser.error("The 'keyword' method requires --keywords to be specified.")
        keyword_map = {}
        for item in args.keywords:
            if ':' not in item:
                parser.error(f"Invalid keyword format '{item}'. Expected KEYWORD:COLOR.")
            key, color = item.split(':', 1)
            keyword_map[key] = color

    try:
        colored_output = colorize_text(
            text=args.text,
            method=args.method,
            colors=args.colors,
            keyword_map=keyword_map
        )
        print(colored_output)
    except ValueError as e:
        parser.error(e)

if __name__ == "__main__":
    main()