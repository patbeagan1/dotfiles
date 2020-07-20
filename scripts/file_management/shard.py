#!/usr/bin/env python3
import os
import time
import subprocess
import argparse
from sys import argv
from os.path import join, getsize
import hashlib
import re

description = """
New Script.
"""

verbosity = 0
verbosity_level = {'quiet': (None, -100), 'error': ('E: ', -2), 'warning': ('W: ', -1),
                   'info': ('', 0), 'debug': ('D: ', 1), 'verbose': ('V: ', 2), 'dump': ('Z: ', 3)}


def dprint(s, s_verbosity_in: str = "info"):
    verbosity_in_prefix, verbosity_in_value = verbosity_level[s_verbosity_in]
    if verbosity == verbosity_level["quiet"]:
        pass
    elif verbosity_in_value <= verbosity:
        print(verbosity_in_prefix + s)


def parse_args():
    parser = argparse.ArgumentParser(description=description)
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "-v", "--verbosity", help="Increases the verbosity level. Supports up to -vvv.", action="count", default=0)
    group.add_argument("-q", "--quiet", action="store_true")

    global verbosity
    args = parser.parse_args()
    if args.quiet:
        verbosity = verbosity_level["quiet"]
    else:
        verbosity = args.verbosity
    return args


def attempt_non_collision_rename(new_name):
    ii = 1
    while True:
        basename = os.path.splitext(new_name)
        new_name = basename[0] + "_" + str(ii) + basename[1]
        if not os.path.exists(new_name):
            return new_name
        ii += 1


if __name__ == "__main__":
    args = parse_args()
    top = os.getcwd()
    files_arr = []
    for root, dirs, files in os.walk(top, topdown=True, onerror=None, followlinks=False):
        print(root, "consumes", end=" ")
        print(sum(getsize(join(root, name)) for name in files), end=" ")
        print("bytes in", len(files), "non-directory files")
        dprint("Test code.", "error")
        curr_dir = os.path.basename(root)
        dirs.clear()

        # checking tmsu is active
        try:
            command = ["tmsu", "files"]
            subprocess.check_call(command)
        except subprocess.CalledProcessError:
            exit("failure running tmsu")
            
        for f in files:

            file_name = f"{root}/{f}"

            with open(file_name, "rb") as in_file:
                
                # getting the hash of the file
                m = hashlib.sha256(in_file.read()).hexdigest()
                
                # generating the short hash directory 
                short_hash = m[0:1]
                if not os.path.exists(short_hash):
                    os.makedirs(short_hash)
                
                
                relative_new_name = m + os.path.splitext(file_name)[1]
                # f"{curr_dir}.{f}"
                new_name = f"{short_hash}/{relative_new_name}"

                # Make sure that we will not collide
                if os.path.exists(new_name):
                    new_name = attempt_non_collision_rename(new_name)

                os.rename(file_name, new_name)
                print("Copied " + file_name + " as " + new_name)
                                
                # adding tags to the file
                try:
                    cleanF = re.sub('\W+','_', f )
                    command = ["tmsu", "tag", f"{new_name}", f"category={curr_dir}", f"original_name={cleanF}"]
                    print(command)
                    subprocess.check_call(command)
                except subprocess.CalledProcessError:
                    exit("failure running tmsu")

    print()
