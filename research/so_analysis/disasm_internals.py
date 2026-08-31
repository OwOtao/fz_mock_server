# -*- coding: utf-8 -*-
"""Disassemble internal functions called by stringDecrypt_core."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

# Functions called by stringDecrypt_core (0x654464)
TARGETS = [
    ("process_raw_bytes (0x653c88)", 0x653c88, 0x200),
    ("magic_check (0x6538d0)", 0x6538d0, 0x100),
    ("key_group_lookup (0x6526e4)", 0x6526e4, 0x100),
    ("aes_setup (0x680f6c)", 0x680f6c, 0x200),
    ("aes_decrypt (0x680a5c)", 0x680a5c, 0x200),
    ("createAes (0x6811ec)", 0x6811ec, 600),
    ("getIv (0x6804e4)", 0x6804e4, 84),
    ("func_0x818688", 0x818688, 0x100),
]

with open(SO_PATH, 'rb') as f:
    elf = ELFFile(f)
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)

    for name, va, size in TARGETS:
        f.seek(va)
        code = f.read(size)
        print(f"\n{'='*60}")
        print(f"--- {name} ---")
        print(f"{'='*60}")
        count = 0
        for insn in md.disasm(code, va):
            line = f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}"
            if insn.mnemonic == 'bl':
                target = int(insn.op_str.replace('#', ''), 16) if insn.op_str.startswith('#') else 0
                if target == 0x6536f4:
                    line += "  ; hexStringToBytes"
                elif target == 0x654a18:
                    line += "  ; stringDecrypt"
                elif target == 0x652794:
                    line += "  ; addInfo"
                elif target == 0x6811ec:
                    line += "  ; createAes"
                elif target == 0x6804e4:
                    line += "  ; getIv"
            print(line)
            count += 1
            if count >= 120:
                print("  ... (truncated)")
                break
