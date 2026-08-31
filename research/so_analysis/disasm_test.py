# -*- coding: utf-8 -*-
"""Disassemble JM::test() to understand the exact call flow."""
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

with open(SO_PATH, 'rb') as f:
    elf = ELFFile(f)
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)

    # JM::test at 0x654b28, size 1768
    va = 0x654b28
    size = 1768
    f.seek(va)
    code = f.read(size)

    print(f"--- JM::test (0x{va:x}, size={size}) ---")
    for insn in md.disasm(code, va):
        line = f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}"
        if insn.mnemonic == 'bl':
            target = int(insn.op_str.replace('#', ''), 16) if insn.op_str.startswith('#') else 0
            if target == 0x6536f4:
                line += "  ; hexStringToBytes"
            elif target == 0x654a18:
                line += "  ; stringDecrypt(Ss)"
            elif target == 0x654464:
                line += "  ; stringDecrypt_core"
            elif target == 0x652794:
                line += "  ; addInfo"
            elif target == 0x6811ec:
                line += "  ; createAes"
            elif target == 0x6804e4:
                line += "  ; getIv"
            elif target == 0x653c88:
                line += "  ; ??(0x653c88)"
            elif target == 0x6538d0:
                line += "  ; ??(0x6538d0)"
            elif target == 0x6526e4:
                line += "  ; ??(0x6526e4)"
            elif target == 0x680f6c:
                line += "  ; ??(0x680f6c)"
            elif target == 0x680a5c:
                line += "  ; ??(0x680a5c)"
            elif target == 0x818688:
                line += "  ; ??(0x818688)"
            else:
                line += f"  ; call 0x{target:x}"
        print(line)
