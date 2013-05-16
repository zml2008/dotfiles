#!/usr/bin/env python

from __future__ import print_function
import os
import shutil
from os.path import *


def check_dir(path):
    dir_name = dirname(path)

    if not isdir(dir_name):
        os.makedirs(dir_name)
    return path

def main():
    root_dir = dirname(__file__)
    home = os.environ["HOME"]
    for root, dirs, files in os.walk(root_dir):
        if root == root_dir: files.remove(basename(__file__))
        if ".git" in dirs: dirs.remove(".git")

        for f in files:
            tip = join(root, f)
            rel_path = tip[(len(root_dir) + 1):]
            home_path = abspath(join(home, rel_path))
            check_dir(home_path)
            print(home_path, "| File:", isfile(home_path), "Link:", isdir(home_path))
            if isfile(home_path) and not islink(home_path):
                bak_path = home_path 
                while isfile(bak_path):
                    bak_path = bak_path + ".bak"

                shutil.move(home_path, bak_path)
            os.remove(home_path)
            os.symlink(abspath(tip), home_path)



if __name__ == "__main__":
    main()
