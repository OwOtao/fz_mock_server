# -*- coding: utf-8 -*-
"""临时提取: sectBuildInfo 建筑名表。用完即删。"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import io
import re

t = io.open(r'fzjh_lua/assets/res/script/family/sectBuildInfo.lua', encoding='utf-8').read()
names = {}
for bid, name in re.findall(r'buildingid="(\d+)",buildname="([^"]+)"', t):
    names[bid] = name
for bid in sorted(names, key=int):
    print('    "%s": "%s",' % (bid, names[bid]))
