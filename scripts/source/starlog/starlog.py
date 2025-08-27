#!/usr/bin/env python3
# (c) 2022 Pat Beagan: MIT License

import datetime
from pathlib import Path

filename = str(Path.home()) + "/starlog.txt"


def prepare_section(f_in):
    def inner(s):
        f_in.write(s + "\n")

    return inner


def indent(s):
    return "\n  " + input(s)


if __name__ == "__main__":
    with open(filename, "a+") as f:
        section = prepare_section(f)
        section("".join(["-" for i in range(40)]))
        section(str(datetime.datetime.now()))
        section("Rating: " + input("How how are you? [-4,4]: "))
        section("Who: " + indent("Who did you see today?"))
        section(
            "Media: "
            + indent("What shows are you watching?")
            + indent("What books are you reading?")
            + indent("What games are you playing?")
        )
        section("Ideas: " + input("Any ideas that you would like to work on?"))
        section(input("Tell me more!\n"))
