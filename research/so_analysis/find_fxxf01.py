# -*- coding: utf-8 -*-
"""定位 FXXF01 密钥组: 枚举 JM 相关符号并反汇编 initLocalKey/addInfo."""
import sys
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)
    targets = {}
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            n = sym.name
            if not n:
                continue
            if ("initLocalKey" in n or "addInfo" in n or "getKey" in n
                    or (n.startswith("_ZN2JM") and ("Key" in n or "key" in n))):
                try:
                    targets[n] = (sym["st_value"], sym["st_size"])
                except KeyError:
                    pass

    print("=== JM key-related symbols ===")
    for n, (va, sz) in sorted(targets.items()):
        print(f"  0x{va:x} size={sz:>6} {n}")

    def va_to_off(va):
        for seg in elf.iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                return va - seg["p_vaddr"] + seg["p_offset"]
        return None

    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    md.detail = True

    for name in ["_ZN2JM12initLocalKeyEv", "_ZN2JM7addInfoESsSsSsc"]:
        if name not in targets:
            continue
        va, sz = targets[name]
        if sz == 0:
            sz = 1024
        off = va_to_off(va)
        f.seek(off)
        code = f.read(sz)
        print(f"\n=== disasm {name} @0x{va:x} ({sz}B) ===")
        for i, insn in enumerate(md.disasm(code, va)):
            print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}")
            if i > 400:
                print("  ...(truncated)")
                break
