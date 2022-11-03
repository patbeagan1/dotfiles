#!/usr/bin/env python3
# (c) 2022 Pat Beagan: MIT License

import os
import sys

"""
Shows how classes in a source code package relate to each other 
by building a graphviz file that shows their dependencies.

1 arg -> the "owner" package name that we should match on. 
Eg, for the "com.example.util", you would do "dependencies.py com.example"
"""

print("Running...")

input = sys.argv[1]

with open("out.dot", "w") as f:
    f.write("digraph {\n")
    for root, dirs, files in os.walk(".", topdown=False):
        for name in files:
            if ".kt" not in name and ".java" not in name and ".py" not in name:
                continue
            fullname = os.path.join(root, name)
            if "build/" in fullname:
                continue
            print(fullname)
            with open(fullname, "r") as g:
                lines = g.readlines()
                lines = filter(lambda x: "import " in x, lines)
                for line in lines:
                    if "*" in line or "`" in line or input not in line:
                        continue
                    line = line.replace("import ", "")
                    line = line.replace(";", "")
                    line = line.replace(".", "_")
                    line = line.replace("-", "_")

                    fullname = fullname.replace("/", ".")
                    fullname = fullname.replace("-", "_")
                    fullname = fullname.replace(".", "_")
                    f.write(fullname + " -> " + line.strip() + "[shape=plaintext] ;\n")
    f.write("}")

print("Complete.")
