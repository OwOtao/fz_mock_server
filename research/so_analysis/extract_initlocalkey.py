# -*- coding: utf-8 -*-
"""提取 JM::initLocalKey 中所有 addInfo 调用, 解析每次注册的 magic/key/iv 字符串地址."""
import re
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH
ADDINFO_VA = 0x652794
INIT_VA = 0x652d78
INIT_SIZE = 2320

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
        end = raw.find(b"\x00")
        return raw[:end] if end >= 0 else raw

    f.seek(va_to_off(INIT_VA))
    code = f.read(INIT_SIZE)
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    md.detail = True
    insns = list(md.disasm(code, INIT_VA))

    # 追踪 adrp/add 形成的地址常量 (简化: 记录最近的 adrp 基址)
    adrp_vals = {}  # reg -> page
    calls = []
    for i, ins in enumerate(insns):
        if ins.mnemonic == "adrp":
            reg = ins.op_str.split(",")[0].strip()
            adrp_vals[reg] = int(ins.op_str.split("#")[-1], 0)
        elif ins.mnemonic == "bl" and ADDINFO_VA == int(ins.op_str.lstrip("#"), 0):
            calls.append(ins.address)

    print(f"addInfo 调用次数: {len(calls)}")
    for c in calls:
        print(f"  call @0x{c:x}")

    # 对每个调用, 向前扫描 ~40 条指令, 重建 x0..x3 来源的字符串地址
    for c in calls:
        idx = next(i for i, ins in enumerate(insns) if ins.address == c)
        window = insns[max(0, idx - 60):idx]
        # 收集 adrp+add 对
        pages = {}
        adds = {}  # dst_reg -> (base_reg, imm)
        for ins in window:
            if ins.mnemonic == "adrp":
                parts = ins.op_str.split(",")
                pages[parts[0].strip()] = int(parts[-1].strip().lstrip("#"), 0)
            elif ins.mnemonic == "add" and len(ins.op_str.split(",")) == 3:
                parts = [p.strip() for p in ins.op_str.split(",")]
                if parts[1] in pages and parts[2].startswith("#"):
                    adds[parts[0]] = (parts[1], int(parts[2].lstrip("#"), 0))
        # 调用前 x0/x1/x2 通常指向栈上 string 对象, 字符串内容来自更早的 add xN, xM, #imm
        # 直接打印窗口内所有解析出的 rodata 地址
        resolved = set()
        for dst, (base, imm) in adds.items():
            addr = pages[base] + imm
            s = read_cstr(addr)
            if s is not None and len(s) > 0:
                resolved.add((addr, s))
        print(f"\n--- call @0x{c:x} 窗口内 rodata 字符串 ---")
        for addr, s in sorted(resolved):
            try:
                txt = s.decode("ascii")
            except UnicodeDecodeError:
                txt = repr(s)
            print(f"  0x{addr:x}: {txt!r}")
