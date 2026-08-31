# -*- coding: utf-8 -*-
"""纯 Python 解析 ELF64 动态符号表, 检查目标符号是否导出。"""
import struct, sys

from _paths import SO_PATH

SO = SO_PATH

def parse(path):
    with open(path, "rb") as f:
        data = f.read()
    assert data[:4] == b"\x7fELF", "not ELF"
    # ELF64 header
    e_shoff = struct.unpack_from("<Q", data, 0x28)[0]
    e_shentsize = struct.unpack_from("<H", data, 0x3A)[0]
    e_shnum = struct.unpack_from("<H", data, 0x3C)[0]
    e_shstrndx = struct.unpack_from("<H", data, 0x3E)[0]

    def get_sh(i):
        off = e_shoff + i * e_shentsize
        return data[off:off + e_shentsize]

    # section header string table
    shstr_hdr = get_sh(e_shstrndx)
    shstr_off = struct.unpack_from("<Q", shstr_hdr, 0x18)[0]
    shstr_size = struct.unpack_from("<Q", shstr_hdr, 0x20)[0]
    shstr = data[shstr_off:shstr_off + shstr_size]

    def sh_name(s):
        end = s.find(b"\x00", 0)
        return s[:end].decode(errors="replace")

    dynsym = dynstr = None
    for i in range(e_shnum):
        h = get_sh(i)
        name_off = struct.unpack_from("<I", h, 0)[0]
        sh_type = struct.unpack_from("<I", h, 4)[0]
        nm = sh_name(shstr[name_off:])
        if sh_type == 11 and nm == ".dynsym":
            dynsym = h
        elif sh_type == 3 and nm == ".dynstr":
            dynstr = h

    if dynsym is None or dynstr is None:
        print("[!] 未找到 .dynsym/.dynstr")
        return []

    sym_off = struct.unpack_from("<Q", dynsym, 0x18)[0]
    sym_size = struct.unpack_from("<Q", dynsym, 0x20)[0]
    entsize = struct.unpack_from("<Q", dynsym, 0x38)[0] or 24
    str_off = struct.unpack_from("<Q", dynstr, 0x18)[0]
    str_size = struct.unpack_from("<Q", dynstr, 0x20)[0]
    strtab = data[str_off:str_off + str_size]

    def cstr(o):
        e = strtab.find(b"\x00", o)
        return strtab[o:e].decode(errors="replace") if e != -1 else ""

    syms = []
    n = sym_size // entsize
    for i in range(n):
        off = sym_off + i * entsize
        st_name = struct.unpack_from("<I", data, off)[0]
        st_info = data[off + 4]
        st_shndx = struct.unpack_from("<H", data, off + 6)[0]
        st_value = struct.unpack_from("<Q", data, off + 8)[0]
        name = cstr(st_name)
        if not name:
            continue
        bind = st_info >> 4
        typ = st_info & 0xF
        syms.append((name, bind, typ, st_value, st_shndx))
    return syms

if __name__ == "__main__":
    syms = parse(SO)
    print("符号总数(含本地符号):", len(syms))
    # 仅导出符号 (GLOBAL/WEAK, SHN_UNDEF 之外)
    exp = [s for s in syms if s[1] in (1, 2) and s[4] != 0]
    print("导出符号数:", len(exp))

    keys = ["stringEncrypt", "stringDecrypt", "createAes", "getAesWithHead",
            "JM", "getAes", "Encrypt", "Decrypt", "Aes", "XXTEA", "getToken", "Token"]
    hits = [s for s in exp if any(k.lower() in s[0].lower() for k in keys)]
    print("--- 导出符号中含关键词 ---")
    for name, bind, typ, val, sh in sorted(hits, key=lambda x: x[0]):
        print("  0x%08x  bind=%d type=%d  %s" % (val, bind, typ, name))
    print("--- 全部导出符号(前120) ---")
    for name, bind, typ, val, sh in sorted(exp, key=lambda x: x[0])[:120]:
        print("  0x%08x  %s" % (val, name))
