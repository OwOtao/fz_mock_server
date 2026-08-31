# -*- coding: utf-8 -*-
"""识别 0x6536f4 / 0x68ccac / 0x6538d0 函数, 反汇编 FXXF03 分支 (0x689c48)."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)
    addrs = {}
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            try:
                va = sym["st_value"]
                if va in (0x6536f4, 0x68ccac, 0x6538d0, 0x653b60):
                    addrs[va] = (sym.name, sym["st_size"])
            except KeyError:
                pass

    print("=== 函数识别 ===")
    for va, (name, sz) in sorted(addrs.items()):
        print(f"  0x{va:x}: {name} (size={sz})")

    def va_to_off(va):
        for seg in elf.iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                return va - seg["p_vaddr"] + seg["p_offset"]
        return None

    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)

    # FXXF03 分支: 0x689c48..0x689d00
    print("\n=== getHttpHeaders FXXF03 分支 (0x689c48 起) ===")
    start = 0x689c18
    off = va_to_off(start)
    f.seek(off)
    code = f.read(0x120)
    for insn in md.disasm(code, start):
        mark = " <== BL addInfo" if insn.address == 0x689c88 else ""
        print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}{mark}")
