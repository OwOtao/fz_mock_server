# -*- coding: utf-8 -*-
"""定位 0x654bd8/0x654ca0/0x689a60/0x689c88 所属函数并反汇编."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH
CALLERS = [0x654bd8, 0x654ca0, 0x689a60, 0x689c88]

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)
    funcs = []
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            try:
                if sym["st_size"] > 0 and sym.entry["st_info"]["type"] == "STT_FUNC":
                    funcs.append((sym["st_value"], sym["st_size"], sym.name))
            except (KeyError, IndexError):
                pass

    def find_func(addr):
        best = None
        for va, sz, name in funcs:
            if va <= addr < va + sz:
                if best is None or va > best[0]:
                    best = (va, sz, name)
        return best

    def va_to_off(va):
        for seg in elf.iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                return va - seg["p_vaddr"] + seg["p_offset"]
        return None

    seen = set()
    for c in CALLERS:
        fn = find_func(c)
        if fn is None:
            print(f"0x{c:x}: 未找到所属函数")
            continue
        va, sz, name = fn
        if va in seen:
            continue
        seen.add(va)
        print(f"\n调用点 0x{c:x} 属于: {name} @0x{va:x} ({sz}B)")

    # 反汇编这些函数 (限制 4KB)
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    for va in sorted(seen):
        fn = next((va2, sz2, n2) for va2, sz2, n2 in funcs if va2 == va)
        _, sz, name = fn
        sz = min(sz, 4096)
        off = va_to_off(va)
        f.seek(off)
        code = f.read(sz)
        print(f"\n{'='*70}\n{name} @0x{va:x}\n{'='*70}")
        count = 0
        for insn in md.disasm(code, va):
            mark = " <== addInfo" if insn.address in CALLERS else ""
            print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
            count += 1
            if count > 600:
                print("  ...(truncated)")
                break
