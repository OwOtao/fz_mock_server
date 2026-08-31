# -*- coding: utf-8 -*-
"""Disassemble cpp::aes::d (0x680710) to see exact key/IV handling."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

with open(SO_PATH, 'rb') as f:
    elf = ELFFile(f)
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)

    # cpp::aes::d at 0x680710, size 436
    va = 0x680710
    size = 436
    f.seek(va)
    code = f.read(size)

    print(f"--- cpp::aes::d (0x{va:x}, size={size}) ---")
    for insn in md.disasm(code, va):
        line = f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}"
        if insn.mnemonic == 'bl':
            target = int(insn.op_str.replace('#', ''), 16) if insn.op_str.startswith('#') else 0
            if target == 0x6804e4:
                line += "  ; getIv"
            elif target == 0x115f750:
                line += "  ; string::operator="
            elif target == 0xfed184:
                line += "  ; AES_set_decrypt_key"
            elif target == 0xfec738:
                line += "  ; AES_cbc_encrypt"
            elif target == 0x680540:
                line += "  ; getTag"
            elif target == 0x68055c:
                line += "  ; cpp::aes::e (encrypt)"
            else:
                line += f"  ; call 0x{target:x}"
        print(line)
