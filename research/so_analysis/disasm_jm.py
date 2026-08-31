# -*- coding: utf-8 -*-
"""Disassemble key JM functions from libcocos2dlua_arm64.so using pyelftools + capstone."""
import struct
from elftools.elf.elffile import ELFFile
from capstone import Cs, CS_ARCH_ARM64, CS_MODE_ARM

from _paths import SO_PATH

TARGET_FUNCS = [
    "_ZN2JM16hexStringToBytesESs",
    "_ZN2JM13stringDecryptESs",
    "_ZN2JM7addInfoESsSsSsc",
    "_ZN3cpp3aes9createAesESsSsSsc",
    "_ZN3cpp3aes5getIvEv",
    "_ZN3cpp3aes7decryptESs",
    "_ZN2JM4testEv",
]

def find_func_addr(elf, name):
    """Find function virtual address and size from dynsym."""
    for section in elf.iter_sections():
        if not hasattr(section, 'iter_symbols'):
            continue
        for sym in section.iter_symbols():
            if sym.name == name and sym['st_info']['type'] == 'STT_FUNC':
                return sym['st_value'], sym['st_size']
    return None, 0

def va_to_offset(elf, va):
    """Convert virtual address to file offset."""
    for seg in elf.iter_segments():
        if seg['p_type'] == 'PT_LOAD':
            if seg['p_vaddr'] <= va < seg['p_vaddr'] + seg['p_filesz']:
                return va - seg['p_vaddr'] + seg['p_offset']
    return None

with open(SO_PATH, 'rb') as f:
    elf = ELFFile(f)
    
    print("=== Finding functions ===")
    func_info = {}
    for name in TARGET_FUNCS:
        va, size = find_func_addr(elf, name)
        if va is not None:
            offset = va_to_offset(elf, va)
            print(f"  {name}: va=0x{va:x} size={size} offset=0x{offset:x}")
            func_info[name] = (va, size, offset)
        else:
            print(f"  {name}: NOT FOUND")
    
    print("\n=== Disassembling ===")
    md = Cs(CS_ARCH_ARM64, CS_MODE_ARM)
    md.detail = True
    
    for name in TARGET_FUNCS:
        if name not in func_info:
            continue
        va, size, offset = func_info[name]
        if size == 0:
            size = 512  # default if size unknown
        
        f.seek(offset)
        code = f.read(size)
        
        print(f"\n--- {name} (va=0x{va:x}, size={size}) ---")
        count = 0
        for insn in md.disasm(code, va):
            # Print address, mnemonic, op_str
            # Also try to resolve ADRP+ADD patterns
            line = f"  0x{insn.address:x}: {insn.mnemonic:8s} {insn.op_str}"
            print(line)
            count += 1
            if count >= 200:  # limit output
                print("  ... (truncated)")
                break
