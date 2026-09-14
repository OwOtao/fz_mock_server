# -*- coding: utf-8 -*-
"""检查各本地覆盖目录文件的尾部 '0' 补填充情况。"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.stdout.reconfigure(encoding="utf-8")

for label, sub in (("debug/", "debug"), ("DebugLayer/", "DebugLayer"), ("patched/", "patched")):
    root = ROOT / sub
    if not root.is_dir():
        print("%s 不存在" % sub)
        continue
    print("=== %s ===" % label)
    for path in sorted(p for p in root.rglob("*") if p.is_file()):
        data = path.read_bytes()
        core = data.rstrip(b"0")
        pad = len(data) - len(core)
        print("  %-28s %7d 字节  尾部补0=%-3d  length%%16=%-3d 去补0后结尾=%r"
              % (path.relative_to(root).as_posix(), len(data), pad, len(data) % 16, core[-18:]))
    print()
