#!/usr/bin/env python3

import os
import time
import subprocess
from sys import argv


def shdo(command):
    """Stands for 'shell do', this will just run a bash command"""
    p = subprocess.Popen(command, shell=True, stderr=subprocess.PIPE)
    return p.communicate()


def shdox(command):
    """Stands for 'shell do explicit', this will just run a bash command"""
    p = subprocess.Popen(command, stderr=subprocess.PIPE)
    return p.communicate()


s_code_starter = '''#!/usr/bin/env python3
import os
import time
import subprocess
import argparse
from sys import argv

description = """
New Script.
"""

##########################################################################################
### Initialization boilerplate, included for portability                               ###
##########################################################################################

verbosity = 0
verbosity_level = {'quiet': (None, -100), 'error': ('E: ', -2), 'warning': ('W: ', -1),
                   'info': ('', 0), 'debug': ('D: ', 1), 'verbose': ('V: ', 2), 'dump': ('Z: ', 3)}


def dprint(s, s_verbosity_in: str = "info"):
    verbosity_in_prefix, verbosity_in_value = verbosity_level[s_verbosity_in]
    if verbosity == verbosity_level["quiet"]:
        pass
    elif verbosity_in_value <= verbosity:
        print(verbosity_in_prefix + s)


def shdo(command):
    if type(command) == str:
        p = subprocess.Popen(command, shell=True, stderr=subprocess.PIPE)
    elif type(command) == list:
        p = subprocess.Popen(command, stderr=subprocess.PIPE)
    else:
        print("No way to infer command usage.")
    return p.communicate()


def parse_args():
    parser = argparse.ArgumentParser(description=description)
    group = parser.add_mutually_exclusive_group()
    group.add_argument(
        "-v", "--verbosity", help="Increases the verbosity level. Supports up to -vvv.", action="count", default=0)
    group.add_argument("-q", "--quiet", action="store_true")

    ####################
    ### Replace here ###
    ####################
    parser.add_argument(
        "pos1", help="The item in the first position.", type=int)
    ####################

    global verbosity
    args = parser.parse_args()
    if args.quiet:
        verbosity = verbosity_level["quiet"]
    else:
        verbosity = args.verbosity
    return args

##########################################################################################
### Script content                                                                     ###
##########################################################################################

if __name__ == "__main__":
    args = parse_args()

    #######################################
    ### Here for example, please delete ###
    #######################################
    dprint("At least: error", "error")
    dprint("At least: warning", "warning")
    dprint("At least: info", "info")
    dprint("At least: debug", "debug")
    dprint("At least: verbose", "verbose")
    dprint("At least: dump", "dump")
    print()

    out, err = shdo(f"echo first:{args.pos1}")
    print(f"Out:{out}, Err:{err}")
    print()

    out, err = shdo(["echo", f"second:{args.pos1}"])
    print(f"Out:{out}, Err:{err}")
    print()
'''

if __name__ == "__main__":
    s_name = argv[1] + ".py"
    with open(s_name, "w") as f:
        f.write(s_code_starter)
    shdo(f"chmod 755 {s_name} && code {s_name}")
