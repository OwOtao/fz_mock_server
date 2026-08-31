# -*- coding: utf-8 -*-
"""反汇编 JM::getKey 和 JM::stringDecrypt, 分析未知魔数回退逻辑."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

TARGETS = [
    ("_ZN2JM6getKeyEPhS0_S0_", 700),
    ("_ZN2JM13stringDecryptESs", None),
]

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)
    addrs = {}
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            if sym.name in [t[0] for t in TARGETS]:
                try:
                    addrs[sym.name] = (sym["st_value"], sym["st_size"])
                except KeyError:
                    pass

    def va_to_off(va):
        for seg in elf.iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                return va - seg["p_vaddr"] + seg["p_offset"]
        return None

    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    md.detail = True

    for name, _ in TARGETS:
        if name not in addrs:
            print(f"{name}: NOT FOUND")
            continue
        va, sz = addrs[name]
        if sz == 0:
            sz = 2048
        off = va_to_off(va)
        f.seek(off)
        code = f.read(sz)
        print(f"\n{'='*60}\n{name} @0x{va:x} ({sz}B)\n{'='*60}")
        for i, insn in enumerate(md.disasm(code, va)):
            print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}")
            if i > 500:
                print("  ...(truncated)")
                break
