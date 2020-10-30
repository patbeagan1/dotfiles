#!/usr/bin/env python3

import os
import sys
import hashlib

dst_id = os.path.expanduser('~/.index/id')
dst_tags = os.path.expanduser('~/.index/')


def main():
    subcommand = sys.argv[1]
    args = sys.argv[2:]
    # 0         1  2 3     4
    # tagger.py -s n tagas j
    global dst_tags
    if subcommand == "-s":
        subcommand = args[1]
        dst_tags = dst_tags + "/tags_" + args[0]
        args = args[2:]
    else:
        dst_tags = dst_tags + "/tags"

    cmd = {
        "tagcheck": cmd_tagcheck,
        "tagas": cmd_tagas,
        "tag": cmd_tag,
        "index": cmd_index
    }.get(subcommand)

    if cmd != None:
        if subcommand not in ["tagcheck"]:
            for it in [dst_id, dst_tags]:
                check_make(it)
        cmd(args)


def cmd_tag(args):
    target = args[0]
    tags = args[1:]
    (path, hashed, hashed_path) = get_hashed_path_from_target(target)
    link(path, hashed_path)

    for i in tags:
        tag_dir = f"{dst_tags}/{i}"
        check_make(tag_dir)
        link(hashed_path, f"{tag_dir}/{hashed}")


def cmd_tagcheck(args):
    target = args[0]
    (_, hashed, _) = get_hashed_path_from_target(target)
    for i in os.scandir(dst_tags):
        if os.path.exists(f"{i.path}/{hashed}"):
            print(i.name)


def cmd_tagas(args):
    tag = args[0]
    targets = args[1:]
    tag_dir = f"{dst_tags}/{tag}"
    check_make(tag_dir)
    inner_tagas(targets, tag_dir)

"""
Unwraps directories and tags everything inside of them. 
This utility is always recursive!
"""
def inner_tagas(targets, tag_dir):
    for target in targets:
        if os.path.isdir(target):
            inner_tagas(os.scandir(target), tag_dir)
        else:
            (path, hashed, hashed_path) = get_hashed_path_from_target(target)
            tag_path = f"{tag_dir}/{hashed}"
            link(path, hashed_path)
            link(hashed_path, tag_path)


def cmd_index(args: list):
    print(args)
    for it in args:
        path = get_rel_path(it)
        dst = get_hash_path(get_hash(path))
        link(path, dst)


def get_hashed_path_from_target(target):
    path = get_rel_path(target)
    hashed = get_hash(target)
    hashed_path = get_hash_path(hashed)
    return (path, hashed, hashed_path)


def link(path, dst):
    try:
        os.unlink(dst)
    except FileNotFoundError:
        pass
    os.symlink(path, dst)
    print(f"symlink created for: {path}")


def get_rel_path(filename: str):
    return '/' + os.path.relpath(filename, start='/')


def get_hash_path(hashed: str):
    return f"{dst_id}/{hashed}"


def get_hash(filename: str):
    BLOCKSIZE = 65536
    hasher = hashlib.sha256()
    try:
        with open(filename, 'rb') as afile:
            buf = afile.read(BLOCKSIZE)
            while len(buf) > 0:
                hasher.update(buf)
                buf = afile.read(BLOCKSIZE)
        return hasher.hexdigest()
    except IsADirectoryError:
        print("We don't support directories!")
        exit(1)


def check_make(dst_dir):
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)


if __name__ == "__main__":
    main()
