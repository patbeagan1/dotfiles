#!/usr/bin/env python3

import datetime
from pathlib import Path

filename = str(Path.home()) + "/starlog.txt"

def prepare_section(f_in):
    def inner(s):
        f_in.write(s + "\n")
    return inner

if __name__ == "__main__":
    with open(filename, "a+") as f:
        section = prepare_section(f)
        section("".join(["-" for i in range(40)]))
        section(str(datetime.datetime.now()))
        section(f"Rating: {input('How how are you? [-4,4]: ')}")
        section(input("Tell me more!\n\n"))
