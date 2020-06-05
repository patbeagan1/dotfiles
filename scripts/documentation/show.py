#!/usr/bin/env python3
import os
import time
import subprocess
import argparse
from sys import argv


description = """
Shows snippets for complicated tools, that are not suited to scripts, but could still be reused via a reference.
"""


magick = """
montage * -geometry 55x55+1+1 out.jpg
"""

urls = {
    "lifecycle":    "https://i.stack.imgur.com/1llRw.png;",
    "versions":     "https://source.android.com/source/build-numbers#platform-code-names-versions-api-levels-and-ndk-releases;",
    "patterns":     "https://i.pinimg.com/736x/5c/33/8e/5c338e86d098eb9955703b00dd3f20ea--programming-patterns-programming-languages.jpg;",
    "cat":          "https://static.pexels.com/photos/45201/kitty-cat-kitten-pet-45201.jpeg;",
    "chair":        "https://secure.img1-fg.wfcdn.com/im/60980607/resize-h800%5Ecompr-r85/2899/28992811/Chrisanna+Wingback+Chair.jpg;"
}


def shdo(command):
    p = subprocess.Popen(command, shell=True, stderr=subprocess.PIPE)
    return p.communicate()


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=description)
    group = parser.add_mutually_exclusive_group()
    group.add_argument("--magick", help="shows common imagemagick snippets", action='store_true')
    group.add_argument("--url", help="opens up web documentation", type=str)
    args = parser.parse_args()

    if args.magick:
        print(magick)
    elif args.url:
        try: 
            url = urls[args.url]
            shdo(f"open {url}")
        except KeyError:
            print("Not a valid url, options are:")
            for k in urls:
                print(f"  {k}")
    else:
        parser.print_help()
