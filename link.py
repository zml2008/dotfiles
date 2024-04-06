#!/usr/bin/env python

from __future__ import print_function
import os
import sys
import shutil
import json
from os.path import *

IGNORE_FILES = [
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


class DotfileLinker(object):
    def __init__(self, root_dir, target_dir=os.environ["HOME"], ignore_files=None, ignore_dirs=None):
        self.root_dir = root_dir
        self.target_dir = target_dir
        self.links_dir = join(root_dir, "links")
        self.instance_name = basename(abspath(root_dir))
        self.load()
        if ignore_files:
            self.ignore_files = ignore_files
        else:
            self.ignore_files = IGNORE_FILES
        if ignore_dirs:
            self.ignore_dirs = ignore_dirs
        else:
            self.ignore_dirs = IGNORE_DIRS

    
    def load(self):
        try:
            with open(join(self.target_dir, "." + self.instance_name + "_links"), 'rt') as f:
                self.known_links = json.load(f)
        except Exception:
            self.known_links = {}

    def save(self):
        with open(join(self.target_dir, "." + self.instance_name + "_links"), 'wt') as f:
            json.dump(self.known_links, f)

    def link(self):
        created_links = {}

        # Create new links, replacing 
        for root, dirs, files in os.walk(self.links_dir):
            for i in self.ignore_dirs:
                if i in dirs: dirs.remove(i)

            for f in files:
                tip = join(root, f)
                rel_path = tip[(len(self.links_dir) + 1):]
                if rel_path in self.ignore_files:
                    continue

                home_path = abspath(join(self.target_dir, rel_path))
                check_dir(home_path)

                if isfile(home_path) and not islink(home_path):
                    bak_path = home_path 
                    while isfile(bak_path):
                        bak_path = bak_path + ".bak"
                    shutil.move(home_path, bak_path)

                if lexists(home_path): os.remove(home_path) # Remove the existing symlink
                os.symlink(abspath(tip), home_path)
                created_links[abspath(tip)] = home_path

        # Remove any dead links we manage
        for k, v in self.known_links.items():
            if not k in created_links:
                try:
                    os.unlink(v)
                except:
                    pass

        self.known_links = created_links
        self.save()


def main():
    sys.stdout.write("Linking symlinks... ")
    print(__file__)
    print(dirname(__file__))
    DotfileLinker(dirname(__file__)).link()
    sys.stdout.write("Done\n")

if __name__ == "__main__":
    main()
