# -*- coding: utf-8 -*-
"""在 2.1.01 的 so 中定位 JHHU 魔数及其配套 key/iv (对比 2.1.02 的 default 组结构)"""

# --- 归类后补充: 保证 mock_server 根目录在 sys.path 上 ---
import os as _reorg_os, sys as _reorg_sys
_REORG_ROOT = _reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.dirname(_reorg_os.path.abspath(__file__))))
if _REORG_ROOT not in _reorg_sys.path:
    _reorg_sys.path.insert(0, _REORG_ROOT)
import re
import sys

sys.stdout.reconfigure(encoding="utf-8")

SO = r"F:\AI\fzjh\libcocos2dlua_arm64.so.bak"   # 原始 2.1.01 so
# 已知 2.1.02 的 default 组: magic=JHHU02 key=cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF iv=PcIQIZifRalhZ88n

with open(SO, "rb") as f:
    b = f.read()
print("so 大小: %d" % len(b))


def dump_context(pos, before=96, after=160):
    start = max(0, pos - before)
    end = min(len(b), pos + after)
    chunk = b[start:end]
    # 打印可打印字符串片段
    strings = re.findall(rb"[\x20-\x7e]{4,}", chunk)
    print("  @0x%x 附近字符串:" % pos)
    for s in strings:
        print("    %r" % s)


for magic in (b"JHHU01", b"JHHU02", b"JHHU03", b"FZJH02", b"FZJH03", b"FXXF03"):
    positions = [m.start() for m in re.finditer(re.escape(magic), b)]
    print("\n=== %r: %d 处 ===" % (magic, len(positions)))
    for pos in positions[:6]:
        dump_context(pos)

# 同时找已知 key 在哪个 so 里, 确认这是 2.1.02 的 key 还是 2.1.01 的
for needle, name in ((b"cbIhHHuYQIJ1JkwlLupIvNIvdQDfNxSF", "default key(JHHU02组)"),
                     (b"PcIQIZifRalhZ88n", "iv PcIQ")):
    print("\n%r (%s): %s" % (needle[:12], name, [m.start() for m in re.finditer(re.escape(needle), b)]))
