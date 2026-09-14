# -*- coding: utf-8 -*-

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import sys

needle = sys.argv[1]
for path in sys.argv[2:]:
    with open(path, encoding="utf-8") as f:
        for i, line in enumerate(f, 1):
            if needle in line:
                print("%s:%d %s" % (path, i, line.rstrip()))
