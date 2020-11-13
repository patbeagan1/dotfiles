#!/usr/bin/env python3

import subprocess
import os
import sys
import hashlib

dst_id = os.path.expanduser('~/.index/id')
dst_tags = os.path.expanduser('~/.index')
dst_nest = os.path.expanduser('~/.index/nest')
debug = False


def usage():
    info = f"""
    This util sets up an index of tagged files at {dst_id}.
    It uses symlinks based on the sha256 hash of an object to make sure the tags are accurate.

    tagger.py [-s TAGSPACE] SUBCMD X [...]
    Supported subcommands:

        help|-h
            Print this usage guide
        tagcheck
            Print the tags that are associated with the following list of files
        tagas
            Tag as X the following list of files
        tag
            Tag X file with the following list of tags
        taglist
            List out the available tags in the current tagspace
        index
            Reindex the file X
        base
            Prints the base file that the tag symlink would eventually point to
        match
            Print files that have all of the following tags
            match -o will open all matched files
        matchany
            Print files that have any of the following tags
    """
    print(info)


def pd(s):
    if debug:
        print(s)


def main():

    if len(sys.argv) < 2:
        usage()
        exit()

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

    if subcommand == "-d":
        subcommand = args[0]
        args = args[1:]
        global debug
        debug = True

    cmd = {
        "help": usage,
        "-h": usage,
        "tagcheck": cmd_tagcheck,
        "tagas": cmd_tagas,
        "tag": cmd_tag,
        "taglist": cmd_taglist,
        "index": cmd_index,
        "base": cmd_basefile,
        "match": cmd_match,
        "matchany": cmd_matchany,
        "nest": cmd_nest
    }.get(subcommand)

    if cmd != None:
        if subcommand in [
            "tagas",
            "tag",
            "index",
            "nest"
        ]:
            for it in [dst_id, dst_tags, dst_nest]:
                check_make(it)
        cmd(args)
    else:
        usage()


def cmd_tag(args):
    target = args[0]
    tags = args[1:]
    (path, hashed, hashed_path) = get_hashed_path_from_target(target)
    link(path, hashed_path)

    for i in tags:
        tag_dir = f"{dst_tags}/{i}"
        check_make(tag_dir)
        link(hashed_path, f"{tag_dir}/{hashed}")


def cmd_taglist(args):
    for i in scan(dst_tags):
        print(i.name)


def cmd_basefile(args):
    for i in args:
        check_available(i)
        print(f"    {os.path.realpath(i)}")


def cmd_tagcheck(args):
    target = args[0]
    (_, hashed, _) = get_hashed_path_from_target(target)
    tags = [
        i.name
        for i in scan(dst_tags)
        if os.path.exists(f"{i.path}/{hashed}")
    ]
    tags.extend(search_nest(tags))
    tagset = sorted(set(tags))
    for i in tagset:
        print(i, end=" ")
    print()


def cmd_matchany(args):
    for tag in args:
        dir_curr = f"{dst_tags}/{tag}"
        for i in scan(dir_curr):
            print(f"{dir_curr}/{i.name}")


def cmd_match(args):
    should_open = False
    if args[0] == "-o":
        should_open = True
        args = args[1:]

    intersection = []
    tags = args

    for tag in tags:
        dir_tag = f"{dst_tags}/{tag}"
        if os.path.exists(dir_tag):
            intersection.append({f"{i.name}" for i in scan(dir_tag)})
        else:
            arr_child_tag = []
            for childtag in search_nest_for_children(tag):
                pd(childtag)
                child_dst_tag = f"{dst_tags}/{childtag}"
                check_make(child_dst_tag)
                arr_child_tag.extend(
                    [f"{i.name}" for i in scan(child_dst_tag)])
            intersection.append(set(arr_child_tag))

    pd(intersection)

    a = None
    for i in intersection:
        if a is None:
            a = i
        else:
            a = a.intersection(i)

    if should_open:
        openall(a)
    else:
        for i in a:
            print(f"{dst_id}/{i}")


def cmd_tagas(args):
    tag = args[0]
    targets = args[1:]
    tag_dir = f"{dst_tags}/{tag}"
    check_make(tag_dir)
    inner_tagas(targets, tag_dir)


def cmd_index(args: list):
    for it in args:
        path = get_rel_path(it)
        dst = get_id_path(get_hash(path))
        link(path, dst)


def cmd_nest(args):
    childname = args[0]
    child = f"{dst_nest}/{childname}"
    parentname = args[1]
    parent = f"{dst_nest}/{parentname}"
    check_make(child)
    check_make(parent)
    link(parent, f"{child}/{parentname}")

################################
# Util methods below
################################


def inner_tagas(targets, tag_dir):
    """
    Unwraps directories and tags everything inside of them. 
    This utility is always recursive!
    """
    for target in targets:
        if os.path.isdir(target):
            pd(target)
            inner_tagas(scan(target), tag_dir)
        else:
            (path, hashed, hashed_path) = get_hashed_path_from_target(target)
            tag_path = f"{tag_dir}/{hashed}"
            link(path, hashed_path)
            link(hashed_path, tag_path)


def get_hashed_path_from_target(target):
    path = get_rel_path(target)
    hashed = get_hash(target)
    hashed_path = get_id_path(hashed)
    return (path, hashed, hashed_path)


def link(path, dst):
    """
    Creates a symlink at dst, which points to path
    """
    try:
        os.unlink(dst)
    except (FileNotFoundError, PermissionError):
        pass
    os.symlink(path, dst)
    print(f"symlink created for: {path}")


def get_rel_path(filename: str):
    """
    Easy way to get relative paths.
    """
    return '/' + os.path.relpath(filename, start='/')


def get_id_path(hashed: str):
    """
    Gets the path of the indexed file. 
    """
    return f"{dst_id}/{hashed}"


def check_available(filename):
    """
    Checks to see if a link is available.
    The most common reason why it wouldn't be - if an external drive is detached.
    """
    if os.path.islink(filename) and not os.path.exists(filename):
        print(f"UNAVAILABLE {filename}")
        return False
    print(f"Available {filename}")
    return True


def openall(filelist):
    """
    Opens all files in the filelist.

    This is open to a lot of improvement. In practice, it doesn't work that well. 
    TODO: find a more elegant solution.
    """
    filelist = [f"{dst_id}/{i}" for i in filelist]
    filelist = [i for i in filelist if check_available(i)]
    chunked = chunks(filelist, 50)

    for bashCommand in chunked:
        bashCommand.insert(0, "open")
        process = subprocess.Popen(bashCommand, stdout=subprocess.PIPE)
        output, error = process.communicate()
        input("Press enter to continue.")
        if error:
            raise Exception(error)


def search_nest_for_children(tag):
    """
    Since the nested tags are organized by child -> parent, 
    we need a way to reverse that and get the children instead.

    TODO: This could be faster if we directly checked for filenames instead of doing 2 scans.
    """
    children = []
    for i in scan(dst_nest):
        if tag in [j.name for j in scan(i)]:
            children.append(i.name)
    pd(children)
    return children


def search_nest(tags):
    """
    Starts a recursive search on all tags that this file has.
    It will print out all tags, and all of their parent tags.
    """
    nest = []
    for i in tags:
        inner_nest(nest, i)
    nest = set(nest)
    return nest


def inner_nest(nest, tag):
    """
    Recurses up the list of parents until it no longer finds ones that it doesn't know about
    """
    pd(tag)
    dir_nest = f"{dst_nest}/{tag}"
    if os.path.exists(dir_nest):
        if tag not in nest:
            nest.append(tag)
            for j in scan(dir_nest):
                inner_nest(nest, j.name)


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
        print("We don't support hashing directories!")


def check_make(dst_dir):
    """Makes a directory in a location, but only if that directory does not already exist."""
    if not os.path.exists(dst_dir):
        os.makedirs(dst_dir)


def chunks(lst, n):
    """Yield successive n-sized chunks from lst."""
    for i in range(0, len(lst), n):
        yield lst[i:i + n]


def scan(directory):
    pd(f"Scanning {directory}")
    res = list(os.scandir(directory))
    if ".notag" not in [i.name for i in res]:
        pd(".notag not found")
        return res
    else:
        pd(".notag found")
        return []


if __name__ == "__main__":
    main()
