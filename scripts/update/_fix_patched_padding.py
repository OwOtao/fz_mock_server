# -*- coding: utf-8 -*-
"""去掉 patched/MainLayer.lua 末尾的 '0' 补填充（保留可逆信息）。"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import hashlib
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parent.parent.parent
sys.stdout.reconfigure(encoding="utf-8")

path = ROOT / "patched" / "MainLayer.lua"
raw = path.read_bytes()
core = raw.rstrip(b"0")
pad = len(raw) - len(core)

print("改动前: %d 字节, md5=%s, 尾部补0=%d, len%%16=%d"
      % (len(raw), hashlib.md5(raw).hexdigest(), pad, len(raw) % 16))
path.write_bytes(core)
now = path.read_bytes()
print("改动后: %d 字节, md5=%s, 尾部补0=%d, len%%16=%d"
      % (len(now), hashlib.md5(now).hexdigest(), len(now) - len(now.rstrip(b"0")), len(now) % 16))
print("结尾: %r" % now[-24:])
restored = now + b"0" * pad
print("可逆: 末尾补回 %d 个 ASCII '0' 即可还原  ->  %s" % (pad, restored == raw))
