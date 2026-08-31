# -*- coding: utf-8 -*-
"""反汇编 JM::isUseXXTEA 与完整 stringDecrypt, 定位 AES/XXTEA 分流."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

TARGETS = [
    "_ZN2JM10isUseXXTEAESs",      # JM::isUseXXTEA(std::string)
    "_ZN2JM13stringDecryptESs",    # JM::stringDecrypt
    "_Z13xxtea_decryptPhjS_jPj",   # xxtea_decrypt
]

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)
    addrs = {}
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            if sym.name in TARGETS:
                try:
                    addrs[sym.name] = (sym["st_value"], sym["st_size"])
                except KeyError:
                    pass

    def va_to_off(va):
        for seg in elf.iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                return va - seg["p_vaddr"] + seg["p_offset"]
        return None

    def read_cstr(va, maxlen=120):
        off = va_to_off(va)
        if off is None:
            return None
        f.seek(off)
        raw = f.read(maxlen)
        e = raw.find(b"\x00")
        return raw[:e] if e >= 0 else raw

    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    md.detail = True

    for name in TARGETS:
        if name not in addrs:
            print(f"{name}: NOT FOUND")
            continue
        va, sz = addrs[name]
        if sz == 0:
            sz = 1200
        off = va_to_off(va)
        f.seek(off)
        code = f.read(sz)
        print(f"\n{'='*70}\n{name} @0x{va:x} ({sz}B)\n{'='*70}")
        for i, insn in enumerate(md.disasm(code, va)):
            # 标注 ADRP+ADD 指向的字符串
            note = ""
            if insn.mnemonic in ("adrp", "add"):
                pass
            print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}{note}")
            if i > 320:
                print("  ...(truncated)")
                break
