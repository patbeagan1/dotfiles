#!/usr/bin/env python3

import datetime
import os
from pathlib import Path
import sys

current_time = datetime.datetime.utcnow()
dateformat = "%Y-%m-%d--%H-%M-%S"
folder = f"{str(Path.home())}/_zettelkasten/"
filename = f"{current_time.strftime(dateformat)}.md"


def main():
    if not os.path.isdir(folder):
        os.mkdir(folder)
    with open(folder + filename, "a+") as f:
        section = prepare_section(f)
        section("".join(["=" for i in range(40)]))
        section(current_time.strftime(dateformat)+"\n")
        if (len(sys.argv) >= 2):
            title = " ".join(sys.argv[1:])
            section(f"# {title}")
        else:
            section(f"# {input('Title: ')}")

        section("".join(["-" for i in range(40)]))
        section(f"Content: {indent('Content: ')}\n")
        section(f"References: {indent('References: ')}\n")


def prepare_section(f_in):
    def inner(s):
        f_in.write(s + "\n")
    return inner


def indent(s):
    return "\n - " + input(s)


if __name__ == "__main__":
    main()
