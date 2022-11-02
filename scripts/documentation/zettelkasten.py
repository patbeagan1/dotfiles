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
        line = prepare_section(f)
        line("".join(["-" for i in range(40)]))
        line(f"written: {current_time.strftime(dateformat)}")
        line("".join(["-" for i in range(40)]))
        line("")
        if len(sys.argv) >= 2:
            title = " ".join(sys.argv[1:])
            line(f"# {title}\n")
        else:
            line(f"# {input('Title: ')}\n")

        line(f"### Content: \n{indent('Content: ')}\n")
        line(f"### References: \n{indent('References: ')}")


def prepare_section(f_in):
    def inner(s):
        f_in.write(f"{s}\n")

    return inner


def indent(s):
    return "\n - " + input(s)


if __name__ == "__main__":
    main()
