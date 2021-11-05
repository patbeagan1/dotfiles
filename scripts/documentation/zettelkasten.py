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
        section(str(datetime.datetime.now()))

        title = " ".join(sys.argv[1:])
        if (len(sys.argv) >= 2):
            section(f"Title: {title}")
        else:
            section("Title: " + input("Title: "))

        section("".join(["-" for i in range(40)]))
        section("Content: " + indent("Content: "))
        section("References: " + indent("References: "))


def prepare_section(f_in):
    def inner(s):
        f_in.write(s + "\n")
    return inner


def indent(s):
    return "\n  " + input(s)


if __name__ == "__main__":
    main()
