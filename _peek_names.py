# -*- coding: utf-8 -*-
"""临时提取: sectBuildInfo 建筑名表。用完即删。"""
import io
import re

t = io.open(r'fzjh_lua/assets/res/script/family/sectBuildInfo.lua', encoding='utf-8').read()
names = {}
for bid, name in re.findall(r'buildingid="(\d+)",buildname="([^"]+)"', t):
    names[bid] = name
for bid in sorted(names, key=int):
    print('    "%s": "%s",' % (bid, names[bid]))
