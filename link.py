#!/usr/bin/env python

from __future__ import print_function
import os
import sys
import shutil
import json
from os.path import *

IGNORE_FILES = [
        basename(__file__),
        "README"
        ]

IGNORE_DIRS = [
        ".git"
        ]

def open_links_file():
    try:
        with open(join(os.environ["HOME"], ".dotfiles_links"), 'rt') as f:
            return json.load(f)
    except Exception:
        return {}

def check_dir(path):
    dir_name = dirname(path)

    if not isdir(dir_name):
        os.makedirs(dir_name)
    return path

def main():
    sys.stdout.write("Linking symlinks... ")
    existing_links = open_links_file()
    created_links = {}

    root_dir = dirname(__file__)
    home = os.environ["HOME"]
    for root, dirs, files in os.walk(root_dir):
        for i in IGNORE_DIRS:
            if i in dirs: dirs.remove(i)

        for f in files:
            tip = join(root, f)
            rel_path = tip[(len(root_dir) + 1):]
            if rel_path in IGNORE_FILES:
                continue

            home_path = abspath(join(home, rel_path))
            check_dir(home_path)

            if isfile(home_path) and not islink(home_path):
                bak_path = home_path 
                while isfile(bak_path):
                    bak_path = bak_path + ".bak"
                shutil.move(home_path, bak_path)

            if lexists(home_path): os.remove(home_path) # Remove the existing symlink
            os.symlink(abspath(tip), home_path)
            created_links[abspath(tip)] = home_path
    for k, v in existing_links.items():
        if not k in created_links:
            os.unlink(v)

    with open(join(os.environ["HOME"], ".dotfiles_links"), 'wt') as f:
        json.dump(created_links, f)

    sys.stdout.write("Done\n")



if __name__ == "__main__":
    main()
