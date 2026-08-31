# -*- coding: utf-8 -*-
"""反汇编内部解密分发函数 0x654464, 定位 XXTEA key 来源; 找 setXXTEAKeyAndSign 调用者."""
import struct
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)

    # 收集符号
    syms = {}
    all_funcs = []
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            try:
                va, sz = sym["st_value"], sym["st_size"]
                if va > 0:
                    syms[sym.name] = (va, sz)
                    if sz > 0:
                        all_funcs.append((va, sz, sym.name))
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

    def disasm_func(va, sz, label, max_insn=500):
        off = va_to_off(va)
        f.seek(off)
        code = f.read(min(sz, 8192))
        md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
        print(f"\n{'='*70}\n{label} @0x{va:x} ({sz}B)\n{'='*70}")
        for i, insn in enumerate(md.disasm(code, va)):
            print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}")
            if i >= max_insn:
                print("  ...(truncated)")
                break

    # 1. 反汇编 0x654464 (stringDecrypt 内部调用)
    # 找它所属函数
    target = 0x654464
    owner = None
    for va, sz, name in all_funcs:
        if va <= target < va + sz:
            owner = (va, sz, name)
    if owner:
        disasm_func(owner[0], owner[1], f"内部解密分发 {owner[2]}")
    else:
        disasm_func(target, 1600, "内部解密分发 (无符号)")

    # 2. 找 setXXTEAKeyAndSign 及其调用者
    xxtea_set = syms.get("_ZN7cocos2d8LuaStack18setXXTEAKeyAndSignEPKciS2_i")
    print(f"\n\nsetXXTEAKeyAndSign: {xxtea_set}")

    # 扫描 BL 到 setXXTEAKeyAndSign
    if xxtea_set:
        tva = xxtea_set[0]
        text_sec = None
        for sec in elf.iter_sections():
            if sec.name == ".text":
                text_sec = (sec["sh_addr"], sec["sh_size"], sec["sh_offset"])
                break
        tva2, tsz, toff = text_sec
        f.seek(toff)
        code = f.read(tsz)
        callers = []
        for i in range(0, len(code) - 3, 4):
            w = struct.unpack_from("<I", code, i)[0]
            if (w >> 26) == 0x25:
                imm = w & 0x3FFFFFF
                if imm & 0x2000000:
                    imm -= 0x4000000
                tgt = (tva2 + i + imm * 4) & 0xFFFFFFFFFFFFFFFF
                if tgt == tva:
                    callers.append(tva2 + i)
        print(f"setXXTEAKeyAndSign 调用点: {[hex(c) for c in callers]}")
        for c in callers:
            # 找所属函数
            for va, sz, name in all_funcs:
                if va <= c < va + sz:
                    print(f"  0x{c:x} in {name} @0x{va:x}")
                    break
