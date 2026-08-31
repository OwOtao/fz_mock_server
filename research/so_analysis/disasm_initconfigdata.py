# -*- coding: utf-8 -*-
"""找 initConfigData JNI 函数并反汇编, 定位 FXXF01 注册."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)
    target = None
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            if "initConfigData" in sym.name:
                try:
                    target = (sym.name, sym["st_value"], sym["st_size"])
                except KeyError:
                    pass

    if target is None:
        print("initConfigData NOT FOUND")
    else:
        name, va, sz = target
        print(f"Found: {name} @0x{va:x} size={sz}")

        def va_to_off(va):
            for seg in elf.iter_segments():
                if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                    return va - seg["p_vaddr"] + seg["p_offset"]
            return None

        def read_cstr(va, maxlen=200):
            off = va_to_off(va)
            if off is None:
                return None
            f.seek(off)
            raw = f.read(maxlen)
            e = raw.find(b"\x00")
            return raw[:e] if e >= 0 else raw

        md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
        off = va_to_off(va)
        f.seek(off)
        code = f.read(min(sz, 8192))

        # 收集 adrp 基址
        adrp_pages = {}
        print(f"\n{'='*70}\n{name} @0x{va:x}\n{'='*70}")
        for insn in md.disasm(code, va):
            if insn.mnemonic == "adrp":
                parts = insn.op_str.split(",")
                adrp_pages[parts[0].strip()] = int(parts[-1].strip().lstrip("#"), 0)

            note = ""
            if insn.mnemonic == "add" and len(insn.op_str.split(",")) == 3:
                parts = [p.strip() for p in insn.op_str.split(",")]
                if parts[1] in adrp_pages and parts[2].startswith("#"):
                    addr = adrp_pages[parts[1]] + int(parts[2].lstrip("#"), 0)
                    s = read_cstr(addr)
                    if s and len(s) > 0:
                        try:
                            txt = s[:60].decode("ascii")
                            if all(32 <= ord(c) < 127 for c in txt):
                                note = f'  ; -> 0x{addr:x} "{txt}"'
                        except:
                            pass

            # 标注 BL addInfo
            mark = ""
            if insn.mnemonic == "bl":
                try:
                    tgt = int(insn.op_str.lstrip("#"), 0)
                    if tgt == 0x652794:
                        mark = " <== BL JM::addInfo"
                    elif tgt == 0x6526e4:
                        mark = " <== BL JM::isUseXXTEA"
                except:
                    pass

            print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}{mark}{note}")
