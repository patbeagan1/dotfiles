#!/usr/bin/env python3

import os
import time
import sys
import calendar
import errno
import shutil

seconds_per_year = 31557600
seconds_per_quarter = seconds_per_year / 4
seconds_since_epoch = int(time.time())


def safe_mkdir(dirname):
    try:
        os.mkdir(dirname)
    except OSError as exc:
        if exc.errno != errno.EEXIST:
            raise
        pass


def get_folder_destination(file_modtime):
    year = time.strftime("%Y", time.gmtime(file_modtime))
    quarter = file_modtime % seconds_per_year / seconds_per_quarter
    quarter = int(quarter % 4)
    if quarter == 0:
        quarter = "Q1-Winter"
    elif quarter == 1:
        quarter = "Q2-Spring"
    elif quarter == 2:
        quarter = "Q3-Summer"
    elif quarter == 3:
        quarter = "Q4-Fall"
    dir_name = year + "-" + str(quarter)
    safe_mkdir(dir_name)
    return dir_name


def walk(top, maxdepth):
    dirs, nondirs = [], []
    for name in os.listdir(top):
        (dirs if os.path.isdir(os.path.join(top, name)) else nondirs).append(name)
    yield top, dirs, nondirs
    if maxdepth > 1:
        for name in dirs:
            for x in walk(os.path.join(top, name), maxdepth - 1):
                yield x


def loop_through_files(root, files):
    for name in files:
        path = os.path.join(root, name)
        try:
            file_modtime = os.path.getmtime(path)
            dst = get_folder_destination(file_modtime)
            shutil.move(path, dst)
        except:
            pass


def main():
    if len(sys.argv) < 2:
        print("Requires the target directory as arg1")
        exit(1)

    if len(sys.argv) == 3:
        print(sys.argv)
        depth = int(sys.argv[2])
        for root, dirs, files in walk(sys.argv[1], depth):
            print("Depth: %s" % depth)
            loop_through_files(root, files)
    else:
        for root, dirs, files in os.walk(sys.argv[1], topdown=False):
            loop_through_files(root, files)

        # for file in os.walk(sys.argv[1]):
        #     print(file)


main()
