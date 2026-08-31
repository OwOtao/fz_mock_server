# -*- coding: utf-8 -*-
"""全量扫描 SO 中所有 BL addInfo / BL xxtea_decrypt / BL isUseXXTEA 调用点."""
import struct
from elftools.elf.elffile import ELFFile

from _paths import SO_PATH

TARGETS = {
    0x652794: "JM::addInfo",
    0x6526e4: "JM::isUseXXTEA",
}

with open(SO_PATH, "rb") as f:
    elf = ELFFile(f)
    # 先动态解析 xxtea_decrypt / xxtea_encrypt 地址
    for sec in elf.iter_sections():
        if not hasattr(sec, "iter_symbols"):
            continue
        for sym in sec.iter_symbols():
            if sym.name in ("_Z13xxtea_decryptPhjS_jPj", "_Z13xxtea_encryptPhjS_jPj",
                            "_ZN2JM13stringDecryptESs", "_ZN2JM13stringEncryptESsSs"):
                try:
                    TARGETS[sym["st_value"]] = sym.name
                except KeyError:
                    pass

    print("目标地址:")
    for va, name in sorted(TARGETS.items()):
        print(f"  0x{va:x} {name}")

    # 找 .text 段范围
    text = None
    for sec in elf.iter_sections():
        if sec.name == ".text":
            text = (sec["sh_addr"], sec["sh_size"], sec["sh_offset"])
            break
    if text is None:
        # fallback: 用第一个 PT_LOAD 可执行段
        for seg in elf.iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_flags"] & 1:
                text = (seg["p_vaddr"], seg["p_filesz"], seg["p_offset"])
                break
    tva, tsz, toff = text
    print(f"\n.text: va=0x{tva:x} size={tsz}")

    f.seek(toff)
    code = f.read(tsz)

    def va_to_off(va):
        for seg in elf.iter_segments():
            if seg["p_type"] == "PT_LOAD" and seg["p_vaddr"] <= va < seg["p_vaddr"] + seg["p_filesz"]:
                return va - seg["p_vaddr"] + seg["p_offset"]
        return None

    def read_cstr(va, maxlen=100):
        off = va_to_off(va)
        if off is None:
            return None
        f.seek(off)
        raw = f.read(maxlen)
        e = raw.find(b"\x00")
        return raw[:e] if e >= 0 else raw

    hits = {va: [] for va in TARGETS}
    for i in range(0, len(code) - 3, 4):
        w = struct.unpack_from("<I", code, i)[0]
        if (w >> 26) == 0x25:  # BL
            imm = w & 0x3FFFFFF
            if imm & 0x2000000:
                imm -= 0x4000000
            target = (tva + i + imm * 4) & 0xFFFFFFFFFFFFFFFF
            if target in hits:
                hits[target].append(tva + i)

    for va, name in sorted(TARGETS.items()):
        callers = hits[va]
        print(f"\n=== {name} @0x{va:x}: {len(callers)} 个调用点 ===")
        for c in callers:
            print(f"  caller @0x{c:x}")
