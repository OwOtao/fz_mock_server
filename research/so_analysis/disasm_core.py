# -*- coding: utf-8 -*-
"""Disassemble specific functions by address."""
import struct
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

# Functions to disassemble: (name, va, size)
TARGETS = [
    ("hex_char_to_nibble (0x6536ac)", 0x6536ac, 0x48),
    ("stringDecrypt_core (0x654464)", 0x654464, 0x400),
    ("createAes (0x6811ec)", 0x6811ec, 600),
    ("getIv (0x6804e4)", 0x6804e4, 84),
    ("JM_test (0x654b28)", 0x654b28, 1768),
]

with open(SO_PATH, 'rb') as f:
    elf = ELFFile(f)
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    md.detail = True

    for name, va, size in TARGETS:
        # For this SO, va == file offset (typical for .so with base 0)
        f.seek(va)
        code = f.read(size)
        print(f"\n{'='*60}")
        print(f"--- {name} ---")
        print(f"{'='*60}")
        for insn in md.disasm(code, va):
            line = f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}"
            # Annotate BL targets
            if insn.mnemonic == 'bl':
                line += "  ; call"
            elif insn.mnemonic == 'adrp':
                line += "  ; page"
            elif insn.mnemonic in ('ldr', 'str', 'ldur', 'stur'):
                line += "  ; mem"
            print(line)
