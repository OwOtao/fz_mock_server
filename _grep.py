# -*- coding: utf-8 -*-
import sys

needle = sys.argv[1]
for path in sys.argv[2:]:
    with open(path, encoding="utf-8") as f:
        for i, line in enumerate(f, 1):
            if needle in line:
                print("%s:%d %s" % (path, i, line.rstrip()))
