#!/bin/python

import os, sys

for root, dirs, files in os.walk("_posts"):
    for filespath in files:
        file_path = os.path.join(root, filespath)
        #os.system(r"sed -i '/include JB/d' %s" % file_path)
        fileName, fileExtension = os.path.splitext(file_path)
        newName = fileName + ".markdown"
        os.rename(file_path, newName)
        print newName

