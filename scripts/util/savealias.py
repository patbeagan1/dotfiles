#!/usr/bin/env python3

import os
import argparse

filename = "../../alias"
filename = os.path.dirname(os.path.realpath(__file__)) + "/" + filename

description = """
New Script.
"""


def parse_args():
    parser = argparse.ArgumentParser(description=description)
    parser.add_argument("name", help="The name of the alias", type=str)
    parser.add_argument("script", help="The content of the alias", type=str)
    args = parser.parse_args()
    return args


if __name__ == "__main__":
    args = parse_args()

    name = args.name
    script = args.script
    script = f"alias {name}='{script}'"

    with open(filename, "a") as f:
        f.write("\n")
        f.write(script)
    print(f'Wrote "{script}" to {filename}')
