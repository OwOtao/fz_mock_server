# -*- coding: utf-8 -*-
"""Usage: python _show.py <file> [start] [end]  (1-based inclusive)."""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import sys

path = sys.argv[1]
start = int(sys.argv[2]) if len(sys.argv) > 2 else 1
end = int(sys.argv[3]) if len(sys.argv) > 3 else 10 ** 9
with open(path, encoding="utf-8") as f:
    lines = f.readlines()
for i in range(start - 1, min(end, len(lines))):
    print("%5d: %s" % (i + 1, lines[i].rstrip()))
