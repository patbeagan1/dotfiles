#!/usr/bin/env python3

import os
import time
import subprocess
from sys import argv


def shdo(command):
    # "shell do" will just run a bash command
    p = subprocess.Popen(command, shell=True, stderr=subprocess.PIPE)
    return p.communicate()


def shdox(command):
    # "shell do" with explicit args, will just run a bash command
    p = subprocess.Popen(command, stderr=subprocess.PIPE)
    return p.communicate()


if __name__ == "__main__":

    shdo("echo hello")
    shdox(["echo", "hello"])

    # catch bad command
    out, err = shdo("hello")
    print(f"Out:{out}, Err:{err}")
