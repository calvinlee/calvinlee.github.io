#!/bin/python

import os, sys

for root, dirs, files in os.walk("_posts"):
    for filespath in files:
        file_path = os.path.join(root, filespath)
        file_h = open(file_path)
        line = file_h.readline()
        while line

