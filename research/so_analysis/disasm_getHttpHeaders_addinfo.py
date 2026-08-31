# -*- coding: utf-8 -*-
"""反汇编 getHttpHeaders 中 addInfo 调用点上下文, 提取 FXXF01 key 来源."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)

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

    # getHttpHeaders @0x6868a0, size=10620
    # addInfo calls at 0x689a60 and 0x689c88
    # 反汇编 0x689900..0x689d00 区域
    start_va = 0x689900
    end_va = 0x689d00
    off = va_to_off(start_va)
    f.seek(off)
    code = f.read(end_va - start_va)

    print(f"=== getHttpHeaders 中 addInfo 调用上下文 (0x{start_va:x}..0x{end_va:x}) ===\n")

    # 收集 adrp 基址用于解析字符串
    adrp_pages = {}
    for insn in md.disasm(code, start_va):
        if insn.mnemonic == "adrp":
            parts = insn.op_str.split(",")
            reg = parts[0].strip()
            page = int(parts[-1].strip().lstrip("#"), 0)
            adrp_pages[reg] = page

        mark = ""
        if insn.address in (0x689a60, 0x689c88):
            mark = " <== BL addInfo"

        # 尝试解析 add 指令中的字符串地址
        note = ""
        if insn.mnemonic == "add" and len(insn.op_str.split(",")) == 3:
            parts = [p.strip() for p in insn.op_str.split(",")]
            base_reg = parts[1]
            if base_reg in adrp_pages and parts[2].startswith("#"):
                addr = adrp_pages[base_reg] + int(parts[2].lstrip("#"), 0)
                s = read_cstr(addr)
                if s is not None and len(s) > 0 and all(32 <= b < 127 for b in s[:min(len(s), 40)]):
                    note = f"  ; -> 0x{addr:x} \"{s[:60].decode('ascii', errors='replace')}\""

        print(f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}{mark}{note}")
