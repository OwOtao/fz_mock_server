# -*- coding: utf-8 -*-
"""定位 0x689a60/0x689c88 所属函数: 找最近的导出符号."""
from elftools.elf.elffile import ELFFile

from _paths import SO_PATH
TARGETS = [0x689a60, 0x689c88]

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)
    syms = []
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            try:
                va = sym["st_value"]
                sz = sym["st_size"]
                if va > 0:
                    syms.append((va, sz, sym.name))
            except KeyError:
                pass

    for t in TARGETS:
        # 找 va <= t 的最大符号
        before = [s for s in syms if s[0] <= t]
        if before:
            best = max(before, key=lambda s: s[0])
            va, sz, name = best
            inside = "在函数内" if (sz > 0 and t < va + sz) else f"(符号 size={sz}, 调用点偏移 +0x{t-va:x})"
            print(f"0x{t:x} -> 最近符号: {name} @0x{va:x} {inside}")
        # 也找 t 之后最近的符号
        after = [s for s in syms if s[0] > t]
        if after:
            nxt = min(after, key=lambda s: s[0])
            print(f"          下一符号: {nxt[2]} @0x{nxt[0]:x} (距离 +0x{nxt[0]-t:x})")
        print()
