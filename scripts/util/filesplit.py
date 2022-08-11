#!/usr/bin/env python3

import sys
import time
import os

folder = str(time.time())
os.mkdir(folder)


def get_filename():
    return folder + "/" + str(time.time()) + ".txt"


if __name__ == '__main__':
    filename = sys.argv[1]
    key = sys.argv[2]
    current_filename = get_filename()
    with open(filename, "r") as f:
        for line in f.readlines():
            if key in line:
                current_filename = get_filename()
            with open(current_filename, "a") as g:
                g.write(line)
