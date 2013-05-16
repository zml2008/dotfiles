#!/usr/bin/env python

from __future__ import print_function
import os
import shutil
from os.path import *

IGNORE_FILES = [
        basename(__file__),
        "README"
        ]

IGNORE_DIRS = [
        ".git"
        ]

def check_dir(path):
    dir_name = dirname(path)

    if not isdir(dir_name):
        os.makedirs(dir_name)
    return path

def main():
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

            os.remove(home_path) # Remove the existing symlink
            os.symlink(abspath(tip), home_path)



if __name__ == "__main__":
    main()
