# -*- coding: utf-8 -*-
import glob
import re

for hf in sorted(glob.glob("handlers/*.py")):
    with open(hf, encoding="utf-8") as f:
        for i, line in enumerate(f, 1):
            if "@route" in line:
                print("%s:%d %s" % (hf, i, line.strip()))
